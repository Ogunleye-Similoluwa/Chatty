import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator_plus/translator_plus.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:rive/rive.dart' as rive;
import 'dart:io';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../helper/ad_helper.dart';
import '../helper/global.dart';
import '../helper/pref.dart';
import '../model/home_type.dart';
import '../widget/home_card.dart';
import '../helper/animation_cache.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _isDarkMode = Get.isDarkMode.obs;
  
  // AI Controllers
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final ImagePicker _picker = ImagePicker();
  final translator = GoogleTranslator();
  
  // ML Kit Vision APIs
  late final ImageLabeler _imageLabeler;
  late final FaceDetector _faceDetector;
  late final TextRecognizer _textRecognizer;
  
  // UI States
  final _isListening = false.obs;
  final _spokenText = ''.obs;
  final _processingImage = false.obs;
  final _aiResponse = ''.obs;
  
  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _slideController;

  // Add new state variables
  final _selectedLanguage = 'English'.obs;
  final _isProcessing = false.obs;
  final List<String> _recentCommands = <String>[].obs;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _initializeAIServices();
    _setupAnimations();
    _preloadAnimations();
  }

  Future<void> _initializeAIServices() async {
    // Initialize Speech Recognition
    await _speechToText.initialize();
    
    // Initialize ML Kit Services
    _imageLabeler = ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.7));
    _faceDetector = FaceDetector(options: FaceDetectorOptions(
      enableLandmarks: true,
      enableClassification: true,
      enableTracking: true
    ));
    _textRecognizer = TextRecognizer();
    
    // Setup TTS with proper configuration
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);  // Slower rate for better clarity
    await _flutterTts.setVolume(1.0);
    
    // Set iOS configuration
    await _flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.ambient,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
      ],
    );
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _preloadAnimations() async {
    final urls = [
      'https://public.rive.app/community/runtime-files/2244-4437-ai-chatbot.riv',
      'https://public.rive.app/community/runtime-files/2196-4348-ai-art-generation.riv',
      'https://public.rive.app/community/runtime-files/1867-3678-translation.riv',
      // Add other URLs...
    ];
    await AnimationCache().preloadAnimations(urls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildExpandableFab(),
      drawer: _buildAIDrawer(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(appName),
      actions: [
        _buildVoiceButton(),
        _buildThemeToggle(),
      ],
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            // Refresh AI models or clear cache
            await _initializeAIServices();
          },
          child: CustomScrollView(
            slivers: [
              _buildWelcomeHeader(),
              _buildAIResponseSection(),
              _buildFeatureGridSection(),
              _buildRecentCommandsSection(),
              _buildMainContentSection(),
            ],
          ),
        ),
        // Loading overlay
        Obx(() => _isProcessing.value
          ? Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          'Processing...',
                          textStyle: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                      repeatForever: true,
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox()),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(mq.width * .04),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chatty',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'What can I help you with today?',
                  textStyle: const TextStyle(color: Colors.white70),
                ),
              ],
              repeatForever: true,
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: -0.2),
    );
  }

  Widget _buildAIResponseSection() {
    return SliverToBoxAdapter(
      child: Obx(() => _aiResponse.value.isEmpty 
        ? const SizedBox() 
        : Card(
            margin: EdgeInsets.all(mq.width * .04),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Response',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(_aiResponse.value),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _speakResponse(_aiResponse.value),
                        child: const Text('Speak'),
                      ),
                      TextButton(
                        onPressed: () => _aiResponse.value = '',
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }

  Widget _buildFeatureGridSection() {
    return SliverPadding(
      padding: EdgeInsets.all(mq.width * .04),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
        ),
        delegate: SliverChildListDelegate([
          _buildAnimatedFeatureCard(
            'Image Analysis',
            'assets/lottie/image_scan.json',
            _processImage,
          ),
          _buildAnimatedFeatureCard(
            'Translation',
            'assets/lottie/translate.json',
            _showTranslationDialog,
          ),
          _buildAnimatedFeatureCard(
            'Face Detection',
            'assets/lottie/face_scan.json',
            _detectFaces,
          ),
          _buildAnimatedFeatureCard(
            'OCR Scanner',
            'assets/lottie/text_scan.json',
            _scanText,
          ),
        ]),
      ),
    );
  }

  Widget _buildAnimatedFeatureCard(String title, String lottieAsset, VoidCallback onTap) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [
                Theme.of(context).cardColor,
                Theme.of(context).cardColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
                width: 60,
                child: Lottie.asset(
                  lottieAsset,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(delay: const Duration(milliseconds: 300))
      .scale(delay: const Duration(milliseconds: 300));
  }

  Future<void> _processImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    _processingImage.value = true;
    try {
      final inputImage = InputImage.fromFile(File(image.path));
      final labels = await _imageLabeler.processImage(inputImage);
      
      final response = labels.map((label) => 
        '${label.label} (${(label.confidence * 100).toStringAsFixed(1)}%)'
      ).join('\n');
      
      _aiResponse.value = 'Image Analysis Results:\n$response';
    } finally {
      _processingImage.value = false;
    }
  }

  Future<void> _detectFaces() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final inputImage = InputImage.fromFile(File(image.path));
      final faces = await _faceDetector.processImage(inputImage);
      
      String result = 'Found ${faces.length} faces\n';
      for (Face face in faces) {
        result += '\nFace ${face.trackingId}:\n';
        result += 'Smiling: ${face.smilingProbability! > 0.5 ? 'Yes' : 'No'}\n';
        result += 'Left eye open: ${face.leftEyeOpenProbability! > 0.5 ? 'Yes' : 'No'}\n';
        result += 'Right eye open: ${face.rightEyeOpenProbability! > 0.5 ? 'Yes' : 'No'}\n';
      }
      
      _aiResponse.value = result;
    } catch (e) {
      _aiResponse.value = 'Error processing image: $e';
    }
  }

  Future<void> _scanText() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    try {
      final inputImage = InputImage.fromFile(File(image.path));
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      _aiResponse.value = 'Detected Text:\n${recognizedText.text}';
    } catch (e) {
      _aiResponse.value = 'Error scanning text: $e';
    }
  }

  Future<void> _speakResponse(String text) async {
    try {
      if (await _flutterTts.speak(text) == 1) { // 1 means success
        _isProcessing.value = true;
        
        _flutterTts.setCompletionHandler(() {
          _isProcessing.value = false;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to speak: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildVoiceButton() {
    return IconButton(
      onPressed: _startListening,
      icon: Obx(() => Icon(
        _isListening.value ? Icons.mic : Icons.mic_none,
        color: _isListening.value ? Colors.red : null,
      )),
    );
  }

  Widget _buildThemeToggle() {
    return IconButton(
      padding: const EdgeInsets.only(right: 10),
      onPressed: () {
        Get.changeThemeMode(_isDarkMode.value ? ThemeMode.light : ThemeMode.dark);
        _isDarkMode.value = !_isDarkMode.value;
        Pref.isDarkMode = _isDarkMode.value;
      },
      icon: Obx(() => Icon(
        _isDarkMode.value ? Icons.brightness_2_rounded : Icons.brightness_5_rounded,
        size: 26,
      )),
    );
  }

  Widget _buildMainContentSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: mq.width * .04,
          vertical: mq.height * .015,
        ),
        child: Column(
          children: HomeType.values.map((e) => HomeCard(homeType: e)).toList(),
        ),
      ),
    );
  }

  Widget _buildExpandableFab() {
    return FloatingActionButton.extended(
      onPressed: _startListening,
      label: Row(
        children: [
          Obx(() => Icon(
            _isListening.value ? Icons.mic : Icons.mic_none,
            color: _isListening.value ? Colors.red : null,
          )),
          const SizedBox(width: 8),
          const Text('Speak'),
        ],
      ),
    ).animate()
      .scale(delay: const Duration(milliseconds: 500))
      .shimmer(delay: const Duration(seconds: 2), duration: const Duration(seconds: 2));
  }

  Future<void> _showTranslationDialog() async {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
    
    Get.dialog(
      AlertDialog(
        title: const Text('Select Target Language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(languages[index]),
                onTap: () {
                  _selectedLanguage.value = languages[index];
                  Get.back();
                  _translateText();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _startListening() async {
    if (!_isListening.value) {
      bool available = await _speechToText.initialize();
      if (available) {
        _isListening.value = true;
        _speechToText.listen(
          onResult: (result) {
            _spokenText.value = result.recognizedWords;
            if (result.finalResult) {
              _isListening.value = false;
              _processVoiceCommand(_spokenText.value);
            }
          },
        );
      }
    } else {
      _isListening.value = false;
      _speechToText.stop();
    }
  }

  void _processVoiceCommand(String command) async {
    if (command.isEmpty) return;
    _aiResponse.value = 'Processing: "$command"';
    // Add your voice command processing logic here
  }

  Future<void> _translateText() async {
    try {
      final text = _spokenText.value.isNotEmpty ? _spokenText.value : 'Hello World';
      final translation = await translator.translate(text, to: 'es');
      _aiResponse.value = 'Translation:\n$text → ${translation.text}';
    } catch (e) {
      _aiResponse.value = 'Translation failed: $e';
    }
  }

  Widget _buildAIDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Features',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Powered by ML Kit & GPT',
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Command History'),
            onTap: () => Get.back(),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('AI Settings'),
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCommandsSection() {
    return SliverToBoxAdapter(
      child: Obx(() => _recentCommands.isEmpty
          ? const SizedBox()
          : Padding(
              padding: EdgeInsets.all(mq.width * .04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Commands',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    _recentCommands.length.clamp(0, 3),
                    (index) => ListTile(
                      title: Text(_recentCommands[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.replay),
                        onPressed: () => _processVoiceCommand(_recentCommands[index]),
                      ),
                    ),
                  ),
                ],
              ),
            )),
    );
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _imageLabeler.close();
    _faceDetector.close();
    _textRecognizer.close();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }
}
