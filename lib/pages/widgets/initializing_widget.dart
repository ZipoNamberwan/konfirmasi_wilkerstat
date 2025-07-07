import 'package:flutter/material.dart';

class InitializingWidget extends StatelessWidget {
  const InitializingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 8,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Logo or Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.assignment,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Loading Animation
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Color(0xFF667eea),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Memuat Assignment...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'Sedang menyiapkan data...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
