import 'dart:async';

import 'package:demandium_provider/feature/in_app_call/repo/in_app_call_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class WebRtcCallSession {
  WebRtcCallSession({required this.repo, required this.callId});

  final InAppCallRepo repo;
  final String callId;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final Set<String> _seenSignalIds = {};
  final List<Map<String, dynamic>> _pendingIceCandidates = [];
  bool _hasRemoteDescription = false;
  bool _iceConnected = false;
  bool _pollingSignals = false;
  String? _lastSignalAfter;
  bool _muted = false;
  bool _onHold = false;
  bool _speakerOn = true;
  final List<Map<String, dynamic>> _outgoingIceBatch = [];
  Timer? _iceBatchTimer;
  Timer? _signalPollLoopTimer;
  Completer<void>? _mediaConnectedCompleter;

  bool get isMuted => _muted;
  bool get isOnHold => _onHold;
  bool get isSpeakerOn => _speakerOn;
  bool get needsSignalPolling => !_iceConnected;

  Future<void> dispose() async {
    try {
      await _localStream?.dispose();
    } catch (_) {}
    try {
      await _remoteStream?.dispose();
    } catch (_) {}
    try {
      await _peerConnection?.close();
    } catch (_) {}
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
    _pendingIceCandidates.clear();
    _iceBatchTimer?.cancel();
    _iceBatchTimer = null;
    _signalPollLoopTimer?.cancel();
    _signalPollLoopTimer = null;
    _outgoingIceBatch.clear();
  }

  Future<void> handleRemoteSignal(Map<String, dynamic> signal) async {
    await _processSignalEntry(signal);
  }

  Future<void> startAsCaller(List<Map<String, dynamic>> iceServers) async {
    await _initPeerConnection(iceServers);
    final offer = await _peerConnection!.createOffer({
      'offerToReceiveAudio': true,
      'offerToReceiveVideo': false,
    });
    await _peerConnection!.setLocalDescription(offer);
    await _postSignal('offer', Map<String, dynamic>.from(offer.toMap()));
    await setSpeakerOn(true);
    await _waitForAnswer();
    await pollPeerSignals();
    _startSignalPollLoop();
    await _waitForMediaConnected();
  }

  Future<void> startAsCallee(List<Map<String, dynamic>> iceServers) async {
    await _initPeerConnection(iceServers);
    await _waitForOffer();
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    await _postSignal('answer', Map<String, dynamic>.from(answer.toMap()));
    await setSpeakerOn(true);
    await pollPeerSignals();
    _startSignalPollLoop();
    await _waitForMediaConnected();
  }

  void _startSignalPollLoop() {
    if (_signalPollLoopTimer != null) return;
    _signalPollLoopTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (!needsSignalPolling) {
        _signalPollLoopTimer?.cancel();
        _signalPollLoopTimer = null;
        return;
      }
      unawaited(pollPeerSignals());
    });
  }

  Future<void> setMuted(bool muted) async {
    _muted = muted;
    for (final track in _localStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !muted;
    }
  }

  Future<void> toggleMute() => setMuted(!_muted);

  Future<void> setOnHold(bool onHold) async {
    _onHold = onHold;
    await setMuted(onHold);
    for (final track in _remoteStream?.getAudioTracks() ?? <MediaStreamTrack>[]) {
      track.enabled = !onHold;
    }
  }

  Future<void> toggleHold() => setOnHold(!_onHold);

  Future<void> setSpeakerOn(bool speakerOn) async {
    _speakerOn = speakerOn;
    await Helper.setSpeakerphoneOn(speakerOn);
  }

  Future<void> toggleSpeaker() => setSpeakerOn(!_speakerOn);

  Future<void> pollPeerSignals() async {
    if (_pollingSignals || !needsSignalPolling) return;

    _pollingSignals = true;
    try {
      final response = await repo.listSignals(
        callId,
        after: _hasRemoteDescription ? _lastSignalAfter : null,
      );
      if (response.statusCode != 200 || response.body['content'] == null) return;

      final signals = response.body['content'];
      if (signals is! List) return;

      for (final raw in signals) {
        if (raw is! Map) continue;
        await _processSignalEntry(Map<String, dynamic>.from(raw));
      }
    } finally {
      _pollingSignals = false;
    }
  }

  Future<void> _processSignalEntry(Map<String, dynamic> signal) async {
    final id = signal['id']?.toString() ?? '';
    if (id.isEmpty || _seenSignalIds.contains(id)) return;

    final createdAt = signal['created_at']?.toString();
    final type = signal['signal_type']?.toString() ?? '';
    final payload = signal['payload'];
    if (payload is! Map) return;
    final payloadMap = Map<String, dynamic>.from(payload);

    if (type == 'offer') {
      if (_hasRemoteDescription) return;
      _seenSignalIds.add(id);
      await _setRemoteDescription(
        RTCSessionDescription(payloadMap['sdp'], payloadMap['type']),
      );
      _advanceSignalCursor(createdAt);
      return;
    }

    if (type == 'answer') {
      if (_hasRemoteDescription) return;
      _seenSignalIds.add(id);
      await _setRemoteDescription(
        RTCSessionDescription(payloadMap['sdp'], payloadMap['type']),
      );
      _advanceSignalCursor(createdAt);
      return;
    }

    if (type == 'ice' && payloadMap['candidate'] != null) {
      _seenSignalIds.add(id);
      if (_hasRemoteDescription) {
        await _handleIceCandidate(payloadMap);
        _advanceSignalCursor(createdAt);
      } else {
        _pendingIceCandidates.add(payloadMap);
      }
    }
  }

  Future<void> _waitForOffer() async {
    for (var i = 0; i < 60; i++) {
      await pollPeerSignals();
      if (_hasRemoteDescription) return;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    throw StateError('Timed out waiting for call offer');
  }

  Future<void> _waitForAnswer() async {
    for (var i = 0; i < 60; i++) {
      await pollPeerSignals();
      if (_hasRemoteDescription) return;
      await Future.delayed(const Duration(milliseconds: 500));
    }
    throw StateError('Timed out waiting for call answer');
  }

  Future<void> _setRemoteDescription(RTCSessionDescription description) async {
    if (_hasRemoteDescription || _peerConnection == null) return;
    await _peerConnection!.setRemoteDescription(description);
    _hasRemoteDescription = true;
    await _flushPendingIceCandidates();
  }

  Future<void> _handleIceCandidate(Map<String, dynamic> payloadMap) async {
    if (!_hasRemoteDescription) {
      _pendingIceCandidates.add(payloadMap);
      return;
    }

    try {
      await _peerConnection?.addCandidate(
        RTCIceCandidate(
          payloadMap['candidate'],
          payloadMap['sdpMid'],
          payloadMap['sdpMLineIndex'],
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('WebRTC ICE error: $e');
      }
    }
  }

  Future<void> _flushPendingIceCandidates() async {
    if (_pendingIceCandidates.isEmpty) return;
    final pending = List<Map<String, dynamic>>.from(_pendingIceCandidates);
    _pendingIceCandidates.clear();
    for (final payloadMap in pending) {
      await _handleIceCandidate(payloadMap);
    }
  }

  void _advanceSignalCursor(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return;
    _lastSignalAfter = createdAt;
  }

  Future<void> _postSignal(String signalType, Map<String, dynamic> payload) async {
    final response = await repo.postSignal(callId, signalType, payload);
    if (response.statusCode != 200) {
      throw StateError('Failed to post $signalType signal');
    }
  }

  void _queueIceCandidate(RTCIceCandidate candidate) {
    _outgoingIceBatch.add({
      'candidate': candidate.candidate,
      'sdpMid': candidate.sdpMid,
      'sdpMLineIndex': candidate.sdpMLineIndex,
    });
    _iceBatchTimer ??= Timer(const Duration(milliseconds: 150), () {
      unawaited(_flushIceBatch());
    });
  }

  Future<void> _flushIceBatch() async {
    _iceBatchTimer?.cancel();
    _iceBatchTimer = null;
    if (_outgoingIceBatch.isEmpty) return;

    final batch = List<Map<String, dynamic>>.from(_outgoingIceBatch);
    _outgoingIceBatch.clear();
    if (batch.length == 1) {
      await _postSignal('ice', batch.first);
      return;
    }
    await _postSignal('ice', {'candidates': batch});
  }

  List<Map<String, dynamic>> _normalizeIceServers(List<Map<String, dynamic>> iceServers) {
    return iceServers.map((server) {
      final normalized = Map<String, dynamic>.from(server);
      final urls = normalized['urls'];
      if (urls is List) {
        normalized['urls'] = urls.map((url) => url.toString()).toList();
      }
      return normalized;
    }).toList();
  }

  Future<void> _initPeerConnection(List<Map<String, dynamic>> iceServers) async {
    final configuration = <String, dynamic>{
      'iceServers': _normalizeIceServers(iceServers),
      'sdpSemantics': 'unified-plan',
    };
    _peerConnection = await createPeerConnection(configuration);
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    });

    for (final track in _localStream!.getTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }

    _peerConnection!.onTrack = (RTCTrackEvent event) {
      if (event.streams.isNotEmpty) {
        _remoteStream = event.streams.first;
      }
      if (event.track.kind == 'audio') {
        event.track.enabled = !_onHold;
      }
    };

    _peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null || candidate.candidate == null || candidate.candidate!.isEmpty) {
        return;
      }
      _queueIceCandidate(candidate);
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _iceConnected = true;
        final completer = _mediaConnectedCompleter;
        if (completer != null && !completer.isCompleted) {
          completer.complete();
        }
      } else if (!_iceConnected &&
          state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
        final completer = _mediaConnectedCompleter;
        if (completer != null && !completer.isCompleted) {
          completer.completeError(StateError('ICE connection failed'));
        }
      }
      if (kDebugMode) {
        print('WebRTC ICE state: $state');
      }
    };
    if (kDebugMode) {
      _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
        print('WebRTC connection state: $state');
      };
    }
  }

  Future<void> _waitForMediaConnected() async {
    if (_iceConnected) return;
    _mediaConnectedCompleter ??= Completer<void>();
    await _mediaConnectedCompleter!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw StateError('Timed out waiting for audio connection'),
    );
  }
}
