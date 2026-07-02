import 'dart:async';
import 'dart:convert';

import 'package:demandium_provider/feature/in_app_call/model/in_app_call_model.dart';
import 'package:demandium_provider/helper/api_url_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pusher_client/pusher_client.dart';

typedef CallStatusHandler = void Function(Map<String, dynamic> payload);
typedef CallSignalHandler = void Function(Map<String, dynamic> signal);

class InAppCallRealtimeService {
  PusherClient? _client;
  Channel? _callChannel;
  String? _subscribedCallId;
  bool _connected = false;
  InAppCallWebSocketConfig? _config;
  CallStatusHandler? _onStatus;
  CallSignalHandler? _onSignal;

  bool get isAvailable => _config?.enabled == true && (_config?.key.isNotEmpty ?? false);
  bool get isConnected => _connected;

  Future<void> connect({
    required InAppCallWebSocketConfig config,
    required String authToken,
    required String apiBaseUrl,
    required String userId,
    required CallStatusHandler onStatus,
  }) async {
    if (!config.enabled || config.key.isEmpty || authToken.isEmpty || userId.isEmpty) {
      return;
    }

    _onStatus = onStatus;
    _config = config;
    await disconnect();

    final baseUrl = ApiUrlHelper.resolveBaseUrl(apiBaseUrl).replaceAll(RegExp(r'/+$'), '');
    final authPath = config.authEndpoint.startsWith('/') ? config.authEndpoint : '/${config.authEndpoint}';
    final authUrl = '$baseUrl$authPath';

    final options = PusherOptions(
      host: _resolveWsHost(config.host),
      wsPort: config.port,
      wssPort: config.port,
      encrypted: config.isSecure,
      auth: PusherAuth(authUrl, headers: {
        'Authorization': 'Bearer $authToken',
        'Accept': 'application/json',
      }),
    );

    _connected = false;
    final connectResult = Completer<bool>();

    _client = PusherClient(
      config.key,
      options,
      enableLogging: kDebugMode,
      autoConnect: false,
    );

    _client!.onConnectionStateChange((change) {
      final state = change?.currentState?.toUpperCase();
      if (state == 'CONNECTED') {
        _connected = true;
        if (!connectResult.isCompleted) {
          connectResult.complete(true);
        }
        return;
      }
      if (state == 'DISCONNECTED' ||
          state == 'FAILED' ||
          state == 'UNAVAILABLE' ||
          state == 'RECONNECTING') {
        _connected = false;
      }
    });

    _client!.onConnectionError((_) {
      _connected = false;
      if (!connectResult.isCompleted) {
        connectResult.complete(false);
      }
    });

    _client!.subscribe('private-in-app-call.user.$userId')
      ..bind('status', (event) => _handleEvent(event, _onStatus));

    await _client!.connect();

    try {
      final connected = await connectResult.future.timeout(
        const Duration(seconds: 6),
        onTimeout: () => false,
      );
      _connected = connected;
    } catch (_) {
      _connected = false;
    }

    if (kDebugMode) {
      print('InAppCall WS connected=$_connected');
    }
  }

  Future<void> subscribeCall(String callId, CallSignalHandler onSignal) async {
    if (_client == null || callId.isEmpty) return;
    if (_subscribedCallId == callId) {
      _onSignal = onSignal;
      return;
    }
    await unsubscribeCall();
    _onSignal = onSignal;
    _subscribedCallId = callId;
    _callChannel = _client!.subscribe('private-in-app-call.$callId')
      ..bind('signal', (event) => _handleEvent(event, _onSignal));
  }

  Future<void> unsubscribeCall() async {
    if (_client != null && _subscribedCallId != null) {
      _client!.unsubscribe('private-in-app-call.$_subscribedCallId');
    }
    _callChannel = null;
    _subscribedCallId = null;
    _onSignal = null;
  }

  Future<void> disconnect() async {
    await unsubscribeCall();
    _client?.disconnect();
    _client = null;
    _connected = false;
    _config = null;
    _onStatus = null;
  }

  void _handleEvent(PusherEvent? event, void Function(Map<String, dynamic>)? handler) {
    if (handler == null || event?.data == null) return;
    try {
      final decoded = jsonDecode(event!.data!);
      if (decoded is Map) handler(Map<String, dynamic>.from(decoded));
    } catch (e) {
      if (kDebugMode) print('InAppCall WS decode error: $e');
    }
  }

  String _resolveWsHost(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty) return trimmed;
    if (kDebugMode && GetPlatform.isAndroid && trimmed == '127.0.0.1') return '10.0.2.2';
    return trimmed;
  }
}
