import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';

void main() {
  runApp(const AnisMobileApp());
}

class AnisMobileApp extends StatelessWidget {
  const AnisMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANIS Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F), // Graphite
        primaryColor: const Color(0xFF00F0FF), // ANIS Cyan
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F0FF),
          secondary: Color(0xFF0051FF),
        ),
      ),
      home: const AnisHomeScreen(),
    );
  }
}

class AnisHomeScreen extends StatefulWidget {
  const AnisHomeScreen({super.key});

  @override
  State<AnisHomeScreen> createState() => _AnisHomeScreenState();
}

class _AnisHomeScreenState extends State<AnisHomeScreen> {
  // ⚠️ IMPORTANT: REPLACE '192.168.1.X' WITH YOUR ACTUAL PC IP ADDRESS!
  // (Find it by typing 'ipconfig' in PowerShell and looking for IPv4 Address)
  final String pcIpAddress = '192.168.1.X'; 
  
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  
  bool _isListening = false;
  String _lastWords = 'Tap the mic and speak...';
  String _anisResponse = 'ANIS is ready.';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) => setState(() => _isListening = val == 'listening'),
      onError: (val) => setState(() => _isListening = false),
    );
    if (!available) {
      setState(() => _lastWords = 'Speech recognition not available.');
    }
  }

  void _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
  }

  void _startListening() async {
    await _speech.listen(onResult: (val) {
      setState(() {
        _lastWords = val.recognizedWords;
      });
    });
  }

  void _stopListening() async {
    await _speech.stop();
    if (_lastWords.isNotEmpty && _lastWords != 'Tap the mic and speak...') {
      _sendCommandToPc(_lastWords);
    }
  }

  Future<void> _sendCommandToPc(String command) async {
    setState(() => _isProcessing = true);
    
    try {
      final response = await http.post(
        Uri.parse('http://$pcIpAddress:8000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': command}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() => _anisResponse = data['response'] ?? 'Command executed.');
        _speakResponse(_anisResponse);
      } else {
        setState(() => _anisResponse = 'Error: Could not reach ANIS PC.');
      }
    } catch (e) {
      setState(() => _anisResponse = 'Connection Error: Is the PC on the same Wi-Fi?');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _speakResponse(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ANIS MOBILE', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: _isProcessing ? Colors.purple : (_isListening ? const Color(0xFF00F0FF) : Colors.green),
                      shape: BoxShape.circle,
                      boxShadow: _isListening || _isProcessing 
                        ? [BoxShadow(color: const Color(0xFF00F0FF), blurRadius: 10)] 
                        : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isProcessing ? 'THINKING...' : (_isListening ? 'LISTENING...' : 'ONLINE'),
                    style: const TextStyle(fontSize: 14, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),

            // Microphone Button
            GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isListening ? 100 : 80,
                height: _isListening ? 100 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening 
                    ? const Color(0xFF00F0FF).withOpacity(0.2) 
                    : Colors.white.withOpacity(0.05),
                  border: Border.all(
                    color: _isListening ? const Color(0xFF00F0FF) : Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: _isListening 
                    ? [const BoxShadow(color: Color(0xFF00F0FF), blurRadius: 30, spreadRadius: 5)] 
                    : [],
                ),
                child: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  size: 40,
                  color: _isListening ? const Color(0xFF00F0FF) : Colors.white70,
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Command Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('YOU:', style: TextStyle(color: Color(0xFF0051FF), fontSize: 12, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(_lastWords, style: const TextStyle(fontSize: 18, color: Colors.white)),
                  const Divider(color: Colors.white24, height: 32),
                  const Text('ANIS:', style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(_anisResponse, style: const TextStyle(fontSize: 18, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}