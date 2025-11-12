import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guita/shared/widgets/gradient_background.dart';
import 'package:guita/shared/widgets/guita_logo.dart';
import 'package:guita/shared/widgets/google_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  static const _catAsset = 'assets/images/mascota.png';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Perillas (hot-reload friendly)
    const double zoomCrop = 0.62;  // 1.0 = sin zoom; menor = más grande
    const double panXPct  = 0.10;  // -1..1 (izq..der)

    final screenWidth = MediaQuery.of(context).size.width;
    final widthFactor =
        screenWidth < 360 ? 0.90 : (screenWidth < 480 ? 0.70 : 0.60);

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const GuitaLogo(size: 56),
                  const SizedBox(height: 24),

                  // Mascota responsiva con zoom + paneo acotado (sin guía)
                  Flexible(
                    child: FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: LayoutBuilder(
                            builder: (context, c) {
                              final leftoverW = c.maxWidth * (1 - zoomCrop);
                              final dx = (leftoverW / 2) * panXPct.clamp(-1.0, 1.0);

                              return ClipRect(
                                child: Transform.translate(
                                  offset: Offset(dx, 0),
                                  child: Align(
                                    widthFactor: zoomCrop,
                                    heightFactor: zoomCrop,
                                    child: Image.asset(
                                      _catAsset,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) =>
                                          Icon(Icons.pets, size: 180, color: cs.primary),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  GoogleButton(
                    text: 'Continuar con Google',
                    onPressed: () => context.go('/connect'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
