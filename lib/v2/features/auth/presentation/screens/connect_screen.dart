import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/config/app_config.dart' as legacy;
import '../../../../core/providers/providers.dart';

class ConnectScreen extends ConsumerStatefulWidget {
  const ConnectScreen({super.key});

  @override
  ConsumerState<ConnectScreen> createState() => _ConnectScreenState();
}

class _ConnectScreenState extends ConsumerState<ConnectScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _testing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _urlController.text = legacy.AppConfig.serverUrl ?? 'http://127.0.0.1:8000';
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  String _normalizeUrl(String raw) {
    var url = raw.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final lower = url.toLowerCase();
      final isLocal = lower.startsWith('localhost') ||
          lower.startsWith('127.') ||
          lower.startsWith('10.') ||
          lower.startsWith('192.168.');
      url = '${isLocal ? 'http' : 'https'}://$url';
    }
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    return url;
  }

  String _apiBaseUrl(String url) =>
      url.endsWith('/api/mobile') ? url : '$url/api/mobile';

  Future<void> _testAndConnect() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _testing = true;
      _error = null;
    });
    try {
      final normalized = _normalizeUrl(_urlController.text);
      final apiUrl = _apiBaseUrl(normalized);
      final dio = Dio(BaseOptions(
        baseUrl: apiUrl,
        connectTimeout: const Duration(seconds: 10),
        headers: {'Accept': 'application/json'},
      ));
      final res = await dio.get(
        '',
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (res.statusCode != null && res.statusCode! >= 200 && res.statusCode! < 500) {
        await legacy.AppConfig.setServerUrl(apiUrl);
        ref.read(apiClientProvider).options.baseUrl = apiUrl;
        if (mounted) context.go('/login');
      } else {
        setState(() => _error = 'Server returned status ${res.statusCode}');
      }
    } on DioException catch (e) {
      setState(() => _error = 'Connection failed: ${e.message}');
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.cloud_outlined, size: 64, color: theme.primaryColor),
                  const SizedBox(height: 16),
                  Text('Connect to Server',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Enter your server URL to get started',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600])),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'http://127.0.0.1:8000',
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    autofocus: true,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter a server URL';
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(color: theme.colorScheme.error)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _testing ? null : _testAndConnect,
                      child: _testing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Connect'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
