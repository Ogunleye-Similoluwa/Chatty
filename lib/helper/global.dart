import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//app name
const appName = 'Chatty';

//media query to store size of device screen
late Size mq;

// Make apiKey mutable for AppWrite
String apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
