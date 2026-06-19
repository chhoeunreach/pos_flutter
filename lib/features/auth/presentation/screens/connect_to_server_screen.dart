import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/server_presets.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/di/injection.dart';

class ConnectToServerScreen extends StatefulWidget {
  const ConnectToServerScreen({super.key});

  @override
  State<ConnectToServerScreen> createState() => _ConnectToServerScreenState();
}

class _ConnectToServerScreenState extends State<ConnectToServerScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _testing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _urlController.text = AppConfig.serverUrl ?? ServerPresets.all.first.url;
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

  void _selectPreset(ServerPreset preset) {
    setState(() {
      _urlController.text = preset.url;
      _error = null;
    });
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _testing = true;
      _error = null;
    });

    final url = _normalizeUrl(_urlController.text);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: _apiBaseUrl(url),
        connectTimeout: const Duration(seconds: 10),
        validateStatus: (status) => status != null && status < 500,
      ));
      await dio.get('/');
      if (!mounted) return;
      setState(() {
        _testing = false;
        _error = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Connection successful'),
            backgroundColor: Colors.green),
      );
    } on DioException {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _error = 'Could not reach server. Check the URL and try again.';
      });
    }
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _testing = true;
      _error = null;
    });

    final url = _normalizeUrl(_urlController.text);
    try {
      final dio = Dio(BaseOptions(
        baseUrl: _apiBaseUrl(url),
        connectTimeout: const Duration(seconds: 10),
        validateStatus: (status) => status != null && status < 500,
      ));
      await dio.get('/');
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _testing = false;
        _error = 'Could not reach server. Check the URL and try again.';
      });
      return;
    }

    final baseUrl = _apiBaseUrl(url);
    await AppConfig.setServerUrl(baseUrl);
    await sl<ApiClient>().updateBaseUrl(baseUrl);

    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_tethering,
                      size: 80, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 16),
                  Text('Connect to Server',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Enter your POS server URL to get started',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey)),
                  const SizedBox(height: 28),
                  _serverPresetPicker(),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      hintText: 'https://your-pos.com',
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.go,
                    onChanged: (_) => setState(() => _error = null),
                    onFieldSubmitted: (_) => _connect(),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter server URL';
                      }
                      final value = v.trim().toLowerCase();
                      if (value == 'localhost' ||
                          value.startsWith('localhost:') ||
                          value.startsWith('http://localhost') ||
                          value.startsWith('https://localhost')) {
                        return null;
                      }
                      if (!value.contains('.')) {
                        return 'Enter a valid domain';
                      }
                      return null;
                    },
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!,
                        style: TextStyle(color: Colors.red[700], fontSize: 13)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _testing ? null : _connect,
                      child: _testing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Connect',
                              style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: _testing ? null : _testConnection,
                      child: _testing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Test Connection'),
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

  Widget _serverPresetPicker() {
    final currentUrl = _urlController.text.trim();
    final selected = currentUrl.isEmpty
        ? null
        : ServerPresets.match(_apiBaseUrl(_normalizeUrl(currentUrl)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Choose server',
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ServerPresets.all.map((preset) {
            final active = selected?.name == preset.name;
            return SizedBox(
              width: 180,
              child: InkWell(
                onTap: _testing ? null : () => _selectPreset(preset),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: active
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        active
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: active
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              preset.name,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              preset.description,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
