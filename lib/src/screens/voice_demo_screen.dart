import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

class VoiceDemoScreen extends StatefulWidget {
  const VoiceDemoScreen({super.key});

  @override
  State<VoiceDemoScreen> createState() => _VoiceDemoScreenState();
}

class _VoiceDemoScreenState extends State<VoiceDemoScreen> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  String _statusMessage = 'Initializing voice services...';
  List<String> _commandHistory = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    // Request microphone permission
    final micPermission = await Permission.microphone.request();
    
    if (!micPermission.isGranted) {
      setState(() {
        _statusMessage = 'Microphone permission required for voice commands';
      });
      return;
    }

    // Initialize speech recognition
    _speechEnabled = await _speechToText.initialize(
      onStatus: _onSpeechStatus,
      onError: _onSpeechError,
    );

    if (_speechEnabled) {
      setState(() {
        _statusMessage = 'Voice activation ready! Say "help" for commands.';
      });
      _speak('Voice activation is ready. Say help for available commands.');
    } else {
      setState(() {
        _statusMessage = 'Speech recognition not available on this device';
      });
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
  }

  void _onSpeechStatus(String status) {
    setState(() {
      if (status == 'listening') {
        _statusMessage = 'Listening for commands...';
      } else if (status == 'notListening') {
        _statusMessage = 'Voice ready - tap to start listening';
      }
    });
  }

  void _onSpeechError(error) {
    setState(() {
      _statusMessage = 'Error: ${error.toString()}';
    });
  }

  void _startListening() async {
    if (_speechEnabled && !_isListening) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: false,
        cancelOnError: false,
        listenMode: ListenMode.confirmation,
      );

      setState(() {
        _isListening = true;
        _statusMessage = 'Listening for commands...';
      });
    } else if (!_speechEnabled) {
      _speak('Speech recognition not enabled. Please grant microphone permission.');
      _initSpeech(); // Try to re-initialize and request permission
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
      _statusMessage = 'Voice ready - tap to start listening';
    });
  }

  void _onSpeechResult(result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if (result.finalResult) {
        _processCommand(_lastWords.toLowerCase());
      }
    });
  }

  void _processCommand(String command) {
    _commandHistory.insert(0, command);
    if (_commandHistory.length > 10) {
      _commandHistory = _commandHistory.take(10).toList();
    }

    // Process voice commands
    if (command.contains('help')) {
      _showHelpDialog();
    } else if (command.contains('home') || command.contains('main')) {
      _speak('Navigating to home');
      context.go('/');
    } else if (command.contains('consumer') || command.contains('dashboard')) {
      _speak('Navigating to consumer dashboard');
      context.go('/consumer');
    } else if (command.contains('food bank') || command.contains('food pantry')) {
      _speak('Finding food banks');
      context.go('/consumer');
    } else if (command.contains('camera') || command.contains('photo')) {
      _speak('Opening camera');
      context.push('/camera');
    } else if (command.contains('chat') || command.contains('ask')) {
      _speak('Opening chat');
      context.push('/askenv-chat');
    } else if (command.contains('supplier')) {
      _speak('Navigating to supplier dashboard');
      context.go('/supplier');
    } else if (command.contains('stop') || command.contains('quiet')) {
      _stopListening();
      _speak('Stopping voice recognition');
    } else {
      _speak('I didn\'t understand that. Say "help" for available commands.');
    }

    setState(() {});
  }

  void _showHelpDialog() {
    _speak('Here are the available voice commands');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Available Voice Commands'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const [
              Text('• "Go to home" - Navigate to main screen'),
              Text('• "Go to consumer dashboard" - Open consumer dashboard'),
              Text('• "Go to supplier dashboard" - Open supplier dashboard'),
              Text('• "Open camera" - Take a photo'),
              Text('• "Open chat" - Start a conversation'),
              Text('• "Find food banks" - Search for food banks'),
              Text('• "Help" - Show this help dialog'),
              Text('• "Stop listening" - Turn off voice recognition'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Activation Demo'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isListening ? Colors.green : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isListening ? _stopListening : _startListening,
                            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                            label: Text(_isListening ? 'Stop Listening' : 'Start Listening'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isListening ? Colors.red : Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _initSpeech,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Re-initialize'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Last Recognized Text
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Recognized:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastWords.isEmpty ? 'Speak a command...' : _lastWords,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            
            // Command History
            Text(
              'Command History:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _commandHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'No commands yet. Say "help" to see available commands.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _commandHistory.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              _commandHistory[index],
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
