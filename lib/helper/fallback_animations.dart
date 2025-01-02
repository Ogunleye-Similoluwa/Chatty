class FallbackAnimations {
  // Simple AI chatbot animation
  static const String chatbot = '''
    {
      "version": 1,
      "artboard": {
        "name": "Chatbot",
        "animations": [
          {
            "name": "Idle",
            "duration": 1,
            "fps": 60,
            "isLooping": true
          }
        ]
      }
    }
  ''';

  // Simple loading animation
  static const String loading = '''
    {
      "version": 1,
      "artboard": {
        "name": "Loading",
        "animations": [
          {
            "name": "Spin",
            "duration": 1,
            "fps": 60,
            "isLooping": true
          }
        ]
      }
    }
  ''';

  // Add more fallback animations...
} 