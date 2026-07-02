import 'dart:isolate';
import 'dart:ui';

/// Single shared isolate port for file-download progress inside chat screens.
class ConversationDownloadPort {
  ConversationDownloadPort._();

  static ReceivePort? _port;
  static final Set<VoidCallback> _listeners = <VoidCallback>{};
  static bool _registered = false;

  static void attach(VoidCallback listener) {
    _listeners.add(listener);
    _ensureRegistered();
  }

  static void detach(VoidCallback listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _teardown();
    }
  }

  static void _ensureRegistered() {
    if (_registered) {
      return;
    }

    _port = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _port!.sendPort,
      'downloader_send_port',
    );
    _port!.listen((_) {
      for (final listener in List<VoidCallback>.from(_listeners)) {
        listener();
      }
    });
    _registered = true;
  }

  static void _teardown() {
    if (!_registered) {
      return;
    }

    IsolateNameServer.removePortNameMapping('downloader_send_port');
    _port?.close();
    _port = null;
    _registered = false;
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, dynamic status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send?.send([id, status, progress]);
  }
}
