import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator_plus/translator_plus.dart';
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';

import '../helper/global.dart';
import '../model/home_type.dart';
import '../widget/home_card.dart';
import '../screen/feature/translator_feature.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _isDarkMode = Get.isDarkMode.obs;
  final _isProcessing = false.obs;
  final _aiResponse = ''.obs;
  
  // Services
  final _picker = ImagePicker();
  final _imageLabeler = GoogleMlKit.vision.imageLabeler();
  final _faceDetector = GoogleMlKit.vision.faceDetector();
  final _textRecognizer = GoogleMlKit.vision.textRecognizer();
  final _speechToText = stt.SpeechToText();
  final _flutterTts = FlutterTts();
  final _translator = GoogleTranslator();
  final _isListening = false.obs;
  final _selectedLanguage = 'es'.obs;
  
  Map<String, Map<String, String>> get _languages => {
    'es': {'name': 'Spanish', 'ttsCode': 'es-MX'},
    'fr': {'name': 'French', 'ttsCode': 'fr-FR'},
    'de': {'name': 'German', 'ttsCode': 'de-DE'},
    'it': {'name': 'Italian', 'ttsCode': 'it-IT'},
    'pt': {'name': 'Portuguese', 'ttsCode': 'pt-BR'},
    'hi': {'name': 'Hindi', 'ttsCode': 'hi-IN'},
    'ja': {'name': 'Japanese', 'ttsCode': 'ja-JP'},
    'ko': {'name': 'Korean', 'ttsCode': 'ko-KR'},
    'zh-cn': {'name': 'Chinese', 'ttsCode': 'zh-CN'},
  };

  bool _speechEnabled = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initSpeechAndTTS();
  }

  Future<void> _initSpeechAndTTS() async {
    try {
      // Initialize TTS with platform-specific settings
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.ambient,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );

      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      // Print available languages and voices
      final languages = await _flutterTts.getLanguages;
      final voices = await _flutterTts.getVoices;
      print('Available TTS languages: $languages');
      print('Available TTS voices: $voices');

      // Initialize speech recognition
      bool available = await _speechToText.initialize(
        onStatus: (String status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening.value = false;
          }
        },
        onError: (error) => print('Speech error: $error'),
      );

      _speechEnabled = available;
      _isInitialized = true;
      setState(() {});
      
      print('Speech recognition available: $available');
    } catch (e) {
      print('TTS Initialization error: $e');
      Get.snackbar('Error', 'Failed to initialize TTS: $e');
    }
  }

  @override
  void dispose() {
    _imageLabeler.close();
    _faceDetector.close();
    _textRecognizer.close();
    _flutterTts.stop();
    _speechToText.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Chatty',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Theme.of(context).primaryColor,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
            child: IconButton(
              icon: Icon(
                _isDarkMode.value ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.white 
                  : Theme.of(context).primaryColor,
              ),
              onPressed: () {
                _isDarkMode.value = !_isDarkMode.value;
                Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Feature Cards
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                final features = [
                  HomeCard(
                    homeType: HomeType.aiChatBot,
                    onTap: HomeType.aiChatBot.defaultNavigation,
                  ),
                  HomeCard(
                    homeType: HomeType.aiImage,
                    onTap: HomeType.aiImage.defaultNavigation,
                  ),
                  HomeCard(
                    homeType: HomeType.aiTranslator,
                    onTap: HomeType.aiTranslator.defaultNavigation,
                  ),
                  HomeCard(homeType: HomeType.imageAnalysis, onTap: _processImage),
                  HomeCard(homeType: HomeType.faceDetection, onTap: _detectFaces),
                  HomeCard(homeType: HomeType.textScanner, onTap: _scanText),
                  HomeCard(homeType: HomeType.voiceTranslator, onTap: _showVoiceTranslatorDialog),
                ];
                return features[index];
              },
            ),
          ),

          // Response Area
          Obx(() => _isProcessing.value 
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _aiResponse.value.isNotEmpty
              ? Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    _aiResponse.value,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                )
              : const SizedBox.shrink()
          ),
        ],
      ),
    );
  }

  Future<void> _processImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      _isProcessing.value = true;
      final inputImage = InputImage.fromFile(File(image.path));
      final labels = await _imageLabeler.processImage(inputImage);
      
      _aiResponse.value = labels.map((label) => 
        '${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)'
      ).join('\n');
    } catch (e) {
      _aiResponse.value = 'Error processing image: $e';
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> _detectFaces() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      _isProcessing.value = true;
      final inputImage = InputImage.fromFile(File(image.path));
      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        _aiResponse.value = 'No faces detected';
        return;
      }

      _aiResponse.value = faces.map((face) => 
        'Face ${faces.indexOf(face) + 1}:\n'
        '${face.smilingProbability != null ? "Smiling: ${(face.smilingProbability! * 100).toStringAsFixed(1)}%\n" : ""}'
        '${face.leftEyeOpenProbability != null ? "Left eye open: ${(face.leftEyeOpenProbability! * 100).toStringAsFixed(1)}%\n" : ""}'
        '${face.rightEyeOpenProbability != null ? "Right eye open: ${(face.rightEyeOpenProbability! * 100).toStringAsFixed(1)}%" : ""}'
      ).join('\n\n');
    } catch (e) {
      _aiResponse.value = 'Error detecting faces: $e';
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> _scanText() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      _isProcessing.value = true;
      final inputImage = InputImage.fromFile(File(image.path));
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      _aiResponse.value = recognizedText.text.isEmpty 
        ? 'No text detected' 
        : recognizedText.text;
    } catch (e) {
      _aiResponse.value = 'Error scanning text: $e';
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> _showVoiceTranslatorDialog() async {
    await Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Text('Voice Translator'),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _stopListening();
                Get.back();
              },
            ),
          ],
        ),
        content: Obx(() => SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Language Selection
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButton<String>(
                  value: _selectedLanguage.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _languages.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(_languages[entry.key]?['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectedLanguage.value = value;
                      // Retranslate if there's existing text
                      if (_aiResponse.value.contains('Original:')) {
                        final originalText = _aiResponse.value
                            .split('\n\n')[0]
                            .replaceAll('Original: ', '');
                        _handleSpeechResult(originalText);
                      }
                    }
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Mic Button
              GestureDetector(
                onTapDown: (_) => _startListening(),
                onTapUp: (_) => _stopListening(),
                onTapCancel: () => _stopListening(),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening.value ? Colors.red : Colors.blue,
                  ),
                  child: Icon(
                    _isListening.value ? Icons.mic : Icons.mic_none,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Text(
                _isListening.value 
                  ? 'Listening...' 
                  : 'Press and hold to speak',
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              // Response Area with Speak Buttons
              if (_aiResponse.value.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_aiResponse.value.contains('Original:')) ...[
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _aiResponse.value.split('\n\n')[0],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () {
                                final originalText = _aiResponse.value
                                    .split('\n\n')[0]
                                    .replaceAll('Original: ', '');
                                _speakText(originalText, 'en-US');
                              },
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _aiResponse.value.split('\n\n')[1],
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () async {
                                final translatedText = _aiResponse.value
                                    .split('\n\n')[1]
                                    .replaceAll('Translated: ', '')
                                    .trim();
                                print('Speaking translated text: $translatedText');
                                await _speakText(translatedText, _selectedLanguage.value);
                              },
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          _aiResponse.value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        )),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      Get.snackbar('Error', 'Speech recognition not initialized');
      return;
    }

    try {
      // Clear previous response
      _aiResponse.value = '';
      
      // Stop if already listening
      if (_speechToText.isListening) {
        await _stopListening();
        return;
      }

      // Start listening
      _isListening.value = true;
      
      final available = await _speechToText.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            _isListening.value = false;
          }
        },
        onError: (error) {
          print('Speech error: $error');
          _isListening.value = false;
          Get.snackbar('Error', error.errorMsg);
        },
      );

      if (available) {
        await _speechToText.listen(
          onResult: (result) {
            if (result.finalResult) {
              _handleSpeechResult(result.recognizedWords);
            } else {
              // Show partial results
              _aiResponse.value = 'Listening: ${result.recognizedWords}';
            }
          },
          listenFor: const Duration(seconds: 10), // Reduced from 30 to 10 seconds
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: 'en_US',
          cancelOnError: true,
          listenMode: stt.ListenMode.dictation, // Changed to dictation mode
        );
      }
    } catch (e) {
      print('Listen error: $e');
      _isListening.value = false;
      Get.snackbar('Error', 'Failed to start listening');
    }
  }

  Future<void> _stopListening() async {
    if (!_speechToText.isListening) return;
    
    try {
      await _speechToText.stop();
      _isListening.value = false;
    } catch (e) {
      print('Stop error: $e');
    }
  }

  Future<void> _handleSpeechResult(String text) async {
    if (text.isEmpty) {
      _aiResponse.value = 'No speech detected';
      return;
    }

    try {
      _aiResponse.value = 'Original: $text\n\nTranslating...';
      
      final translation = await _translator.translate(
        text,
        from: 'auto',
        to: _selectedLanguage.value,
      );
      
      _aiResponse.value = 'Original: $text\n\nTranslated: ${translation.text}';
      
      // Don't auto-speak, let user choose when to play
    } catch (e) {
      print('Translation error: $e');
      _aiResponse.value = 'Translation error: $e';
    }
  }

  Future<void> _speakText(String text, String languageCode) async {
    try {
      print('Speaking text: $text in language: $languageCode');
      
      await _flutterTts.stop();
      
      // Get the correct TTS code
      final ttsCode = _languages[languageCode]?['ttsCode'] ?? 'en-US';
      print('Using TTS code: $ttsCode');

      // Configure TTS with maximum volume
      await _flutterTts.setVolume(1.0);       // Maximum volume
      await _flutterTts.setPitch(1.0);        // Slightly higher pitch for clarity
      await _flutterTts.setSpeechRate(0.4);   // Slower rate for better understanding
      await _flutterTts.setLanguage(ttsCode);
      
      // Set platform-specific options
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
        );
      }

      // Speak with maximum volume
      final result = await _flutterTts.speak(text);
      print('Speak result: $result');

      if (result == 0) {
        Get.snackbar('Error', 'Failed to speak text');
      }
    } catch (e) {
      print('TTS error: $e');
      Get.snackbar('Error', 'Failed to speak: $e');
    }
  }
}
