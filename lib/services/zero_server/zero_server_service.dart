import 'dart:io';
import 'package:anymex/utils/logger.dart';
import 'package:anymex_extension_runtime_bridge/Settings/KvStore.dart';
import 'package:http/http.dart' as http;
import 'package:m_extension_server/m_extension_server.dart';

class ZeroServerService {
  static final ZeroServerService _instance = ZeroServerService._internal();
  factory ZeroServerService() => _instance;
  ZeroServerService._internal();

  final _server = MExtensionServer();
  bool _isStarting = false;

  Future<bool> isRunning() async {
    final port = getVal<int>('zero_server_port');
    if (port == null || port <= 0) return false;
    try {
      final res = await http.get(Uri.parse('http://127.0.0.1:$port/')).timeout(const Duration(seconds: 2));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> startServer() async {
    if (!Platform.isIOS || _isStarting) return;
    _isStarting = true;
    try {
      final running = await isRunning();
      if (!running) {
        final temp = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final port = temp.port;
        await temp.close();
        await _server.startServer(port);
        setVal('zero_server_port', port);
        Logger.i('Zero embedded extension server started on port $port', 'ZERO_SERVER');
      }
    } catch (e) {
      Logger.e('Failed to start Zero extension server: $e', 'ZERO_SERVER');
    } finally {
      _isStarting = false;
    }
  }

  Future<void> stopServer() async {
    if (!Platform.isIOS) return;
    try {
      await _server.stopServer();
    } catch (_) {}
  }
}
