import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';

class QuillHelpers {
  static String getPlainTextFromQuillJson(String jsonText) {
    if (jsonText.isEmpty) return '';
    
    try {
      final deltaJson = jsonDecode(jsonText) as List;
      final delta = Delta.fromJson(deltaJson);
      final document = quill.Document.fromDelta(delta);
      return document.toPlainText().trim();
    } catch (e) {
      return jsonText.trim();
    }
  }
  
  static bool hasContent(String jsonText) {
    final plainText = getPlainTextFromQuillJson(jsonText);
    return plainText.isNotEmpty;
  }
}
