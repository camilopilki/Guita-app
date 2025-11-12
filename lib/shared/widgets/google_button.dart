import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onPressed, this.text = 'Regístrate aquí'});
  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Image.asset('assets/icons/google.png', height: 20),
      label: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(width: 6),
        const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
      ]),
    );
  }
}
