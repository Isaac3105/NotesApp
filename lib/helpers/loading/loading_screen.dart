import 'dart:async';
import 'package:flutter/material.dart';
import 'package:notes_app/helpers/loading/loading_screen_controller.dart';

class LoadingScreen {
  factory LoadingScreen() => _shared;
  static final LoadingScreen _shared = LoadingScreen._sharedInstance();
  LoadingScreen._sharedInstance();

  LoadingScreenController? controller;

  void hide() {
    controller?.close();
    controller = null;
  }

  void show({
    required BuildContext context,
    required String text,
  }) {
    if(controller?.update(text) ?? false){
      return;
    } else{
      controller = showOverlay(context: context, text: text);
    }
  }

  LoadingScreenController showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final textStream = StreamController<String>(); 
    textStream.add(text);

    final state = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    
    // Get theme-aware colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final overlay = OverlayEntry(builder: (context){
      return Material(
        color: Colors.black.withAlpha(isDark ? 220 : 180), // Darker overlay for dark theme
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: size.width * 0.85,
              maxHeight: size.height * 0.3,
              minWidth: size.width * 0.6,
            ),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? (isDark ? Colors.grey[850] : Colors.white),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(50),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? Colors.amber.withAlpha(30) 
                          : Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  StreamBuilder(
                    stream: textStream.stream, 
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            Text(
                              snapshot.data as String,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Please wait...",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  
    state.insert(overlay);

    return LoadingScreenController(
      close: () {
        textStream.close();
        overlay.remove();
        return true;
      }, 
      update: (text) {
        textStream.add(text);
        return true;
      },
    );
  }
}