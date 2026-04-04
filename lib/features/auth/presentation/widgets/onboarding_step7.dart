import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get_it/get_it.dart';
import '../../../../core/services/gemini_key_service.dart';

class OnboardingStep7 extends StatefulWidget {
  final String apiKey;
  final Function(String) onKeyChanged;

  const OnboardingStep7({
    super.key,
    required this.apiKey,
    required this.onKeyChanged,
  });

  @override
  State<OnboardingStep7> createState() => _OnboardingStep7State();
}

class _OnboardingStep7State extends State<OnboardingStep7> {
  final _keyController = TextEditingController();
  final _keyService = GetIt.I<GeminiKeyService>();
  bool _isValidating = false;
  ApiKeyValidationResult? _validationResult;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _keyController.text = widget.apiKey;
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _validateKey() async {
    if (_keyController.text.isEmpty) return;

    setState(() {
      _isValidating = true;
      _validationResult = null;
    });

    final result = await _keyService.validateKey(_keyController.text);

    if (mounted) {
      setState(() {
        _isValidating = false;
        _validationResult = result;
      });
      if (result == ApiKeyValidationResult.valid) {
        widget.onKeyChanged(_keyController.text);
      }
    }
  }

  Future<void> _launchAIStudio() async {
    final url = Uri.parse('https://aistudio.google.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInRight(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Connect AI Meal Parsing 🤖',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Paste your free Gemini API key to enable smart meal recognition.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _keyController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Gemini API Key',
                  hintText: 'AIzaSy...',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                onChanged: (val) {
                  setState(() => _validationResult = null);
                  widget.onKeyChanged(val);
                },
              ),
              const SizedBox(height: 16),
              if (_validationResult != null) ...[
                _buildValidationFeedback(),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isValidating ? null : _validateKey,
                  icon: _isValidating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified),
                  label: Text(_isValidating ? 'Testing your key...' : 'Verify Key'),
                ),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _launchAIStudio,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Get your free key from Google AI Studio →'),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Privacy Note',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your key is stored only on this device using OS-level encryption. We never transmit or store it on any server.',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValidationFeedback() {
    switch (_validationResult!) {
      case ApiKeyValidationResult.valid:
        return const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('AI parsing activated! 🎉', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        );
      case ApiKeyValidationResult.invalid:
        return const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text('Key not recognized. Double-check you copied it fully.', style: TextStyle(color: Colors.red))),
          ],
        );
      case ApiKeyValidationResult.rateLimited:
        return const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Expanded(child: Text('Key is valid but currently rate limited. Try again in a minute.', style: TextStyle(color: Colors.orange))),
          ],
        );
      case ApiKeyValidationResult.networkError:
        return Row(
          children: [
            Expanded(child: Text("Couldn't connect. Check your internet and try again.", style: TextStyle(color: Theme.of(context).disabledColor))),
          ],
        );
    }
  }
}
