// lib/features/connect/connect_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guita/shared/widgets/gradient_background.dart';
import 'package:guita/shared/widgets/guita_logo.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});
  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  bool scanning = false;
  bool connected = false;
  String petName = 'Name Cat';
  String? chosenDevice;
  List<String> found = const [];

  // 👉 Ruta del asset de la mascota
  static const String _mascotaAsset = 'assets/images/mascota.png';

  Future<void> _startScan() async {
    setState(() {
      scanning = true;
      connected = false;
      chosenDevice = null;
      found = const [];
    });
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    setState(() {
      scanning = false;
      found = const ['GuitaMeter-1234', 'GuitaMeter-56A9', 'GuitaMeter-Lite'];
    });
  }

  Future<void> _connect() async {
    setState(() => scanning = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      scanning = false;
      connected = true;
    });
  }

  void _reset() {
    setState(() {
      scanning = false;
      connected = false;
      chosenDevice = null;
      found = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Stack(
            children: [
              // Acción flotante arriba
              Positioned(
                right: 12,
                top: 6,
                child: TextButton.icon(
                  onPressed: _reset,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
                  label: const Text('Reiniciar'),
                ),
              ),

              // Contenido centrado
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 10),
                        const GuitaLogo(size: 48),
                        const SizedBox(height: 16),

                        Text(
                          petName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          connected
                              ? '¡Conectado a tu sensor!'
                              : 'Conéctate por Bluetooth con tu sensor',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .92),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Tarjeta central
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white.withValues(alpha: .22)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .12),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: .1),
                                  border: Border.all(color: Colors.white.withValues(alpha: .25)),
                                ),
                                child: Icon(
                                  connected
                                      ? Icons.bluetooth_connected
                                      : scanning
                                          ? Icons.bluetooth_searching
                                          : Icons.bluetooth,
                                  size: 54,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                connected
                                    ? '¡Conectado!'
                                    : scanning
                                        ? 'Buscando dispositivos…'
                                        : (found.isEmpty ? 'Listo para buscar' : 'Selecciona un dispositivo'),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),

                              if (!scanning && found.isNotEmpty && !connected) ...[
                                const SizedBox(height: 14),
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxHeight: 180),
                                  child: ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: found.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                                    itemBuilder: (_, i) {
                                      final dev = found[i];
                                      final selected = dev == chosenDevice;
                                      return _DeviceTile(
                                        name: dev,
                                        selected: selected,
                                        onTap: () => setState(() => chosenDevice = dev),
                                      );
                                    },
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              if (!connected)
                                FilledButton.icon(
                                  onPressed: scanning
                                      ? null
                                      : (found.isEmpty ? _startScan : (chosenDevice == null ? null : _connect)),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  ),
                                  icon: Icon(found.isEmpty ? Icons.search : Icons.link),
                                  label: Text(found.isEmpty
                                      ? 'Buscar dispositivo'
                                      : (chosenDevice == null ? 'Selecciona uno' : 'Conectar')),
                                ),

                              if (connected)
                                FilledButton.icon(
                                  onPressed: () => context.go('/dashboard'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.arrow_forward),
                                  label: const Text('Ir al panel'),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ── BURBUJA + BADGES + MASCOTA (imagen en assets/images) ─────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // badge “!”
                            const _Badge(
                              icon: Icons.priority_high,
                              background: Color(0xFF7ED957),
                              iconColor: Colors.black,
                            ),
                            const SizedBox(width: 10),

                            // Burbuja con sombra + badge bluetooth
                            Expanded(
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _HelpBubble(
                                    text: connected
                                        ? '¡Excelente! Tu sensor ya está enlazado. Ve al panel cuando quieras.'
                                        : 'Enciende tu medidor, acércalo al teléfono y presiona “Buscar dispositivo”.',
                                  ),
                                  const Positioned(
                                    right: -8,
                                    top: -10,
                                    child: _Badge(
                                      icon: Icons.bluetooth,
                                      background: Color(0xFF7ED957),
                                      iconColor: Colors.black,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 18),

                            // ⬇️ Imagen de la mascota en vez de la patita
                            Image.asset(
                              _mascotaAsset,
                              width: (MediaQuery.of(context).size.width * 0.26)
                                  .clamp(96.0, 150.0),
                              fit: BoxFit.contain,
                              // fallback por si el asset falla
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.pets, size: 96, color: Colors.white),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;
  const _DeviceTile({required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: .22) : Colors.white.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withValues(alpha: .25),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.memory, color: Colors.white.withValues(alpha: .95)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────── Widgets de apoyo ──────────────────────────

class _HelpBubble extends StatelessWidget {
  final String text;
  const _HelpBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 42, 16), // más aire y margen para el badge
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .90),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color iconColor;
  final double size;
  const _Badge({
    required this.icon,
    required this.background,
    required this.iconColor,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .18),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: iconColor, size: size * 0.55),
    );
  }
}
