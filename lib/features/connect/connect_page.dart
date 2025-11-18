// lib/features/connect/connect_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guita/shared/widgets/gradient_background.dart';
import 'package:guita/shared/widgets/guita_logo.dart';
import 'package:guita/ble/ble_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ConnectPage extends StatefulWidget {
  const ConnectPage({super.key});
  @override
  State<ConnectPage> createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  final BleService _bleService = BleService();
  
  bool scanning = false;
  bool connected = false;
  String petName = 'Name Cat';
  String? chosenDevice;
  List<String> found = const [];
  String errorMessage = '';

  // 👉 Ruta del asset de la mascota
  static const String _mascotaAsset = 'assets/images/mascota.png';

  @override
  void initState() {
    super.initState();
    _bleService.dataStream.listen((data) {
      print('📊 Dato recibido desde Arduino: $data');
    });
  }

  @override
  void dispose() {
    // cuando el usuario navegue a otras páginas
    super.dispose();
  }

  Future<bool> _requestPermissions() async {
    print('🔐 Solicitando permisos BLE y ubicación...');
    
    // En Android 12+ (API 31+) necesitamos permisos específicos de Bluetooth
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    bool allGranted = statuses.values.every((status) => status.isGranted);
    
    if (allGranted) {
      print('✅ Todos los permisos concedidos');
      return true;
    } else {
      print('❌ Permisos denegados: $statuses');
      
      // Verificar si algún permiso fue denegado permanentemente
      bool permanentlyDenied = statuses.values.any((status) => status.isPermanentlyDenied);
      
      if (permanentlyDenied) {
        _showPermissionSettingsDialog();
      } else {
        _showPermissionDeniedDialog();
      }
      
      return false;
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos necesarios'),
        content: const Text(
          'Esta aplicación necesita permisos de Bluetooth y Ubicación para escanear dispositivos BLE.\n\n'
          'Por favor, acepta los permisos para continuar.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startScanAndConnect();
            },
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos denegados'),
        content: const Text(
          'Los permisos de Bluetooth fueron denegados permanentemente.\n\n'
          'Por favor, ve a Configuración y habilita los permisos manualmente.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }

  Future<void> _startScanAndConnect() async {
    setState(() {
      scanning = true;
      connected = false;
      chosenDevice = null;
      found = const [];
      errorMessage = '';
    });

    try {
      // Primero solicitar permisos
      bool permissionsGranted = await _requestPermissions();
      
      if (!permissionsGranted) {
        setState(() {
          scanning = false;
          errorMessage = 'Permisos necesarios no concedidos';
        });
        return;
      }

      print('🔍 Iniciando escaneo BLE real...');
      
      // Llamar al servicio BLE para escanear y conectar
      await _bleService.scanAndConnect();
      
      if (!mounted) return;
      
      // Si llegamos aquí, la conexión fue exitosa
      setState(() {
        scanning = false;
        connected = true;
        chosenDevice = 'GuitaBLE';
        found = ['GuitaBLE'];
      });
      
      print('✅ Conexión BLE establecida exitosamente');
      
    } catch (e) {
      print('❌ Error en conexión BLE: $e');
      
      if (!mounted) return;
      
      setState(() {
        scanning = false;
        connected = false;
        chosenDevice = null;
        found = const [];
        errorMessage = 'Error: No se pudo conectar. Verifica que el Arduino esté encendido y cerca.';
      });
      
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error de conexión'),
        content: Text('No se pudo conectar al dispositivo BLE:\n\n$error\n\n'
            'Asegúrate de que:\n'
            '• El Bluetooth esté activado\n'
            '• El Arduino esté encendido\n'
            '• El dispositivo esté cerca\n'
            '• Los permisos de Bluetooth estén otorgados'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startScanAndConnect();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Future<void> _disconnect() async {
    await _bleService.disconnect();
    setState(() {
      scanning = false;
      connected = false;
      chosenDevice = null;
      found = const [];
      errorMessage = '';
    });
  }

  void _reset() {
    _disconnect();
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
                                    ? '¡Conectado a GuitaBLE!'
                                    : scanning
                                        ? 'Buscando GuitaBLE…'
                                        : 'Listo para buscar',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                              ),

                              if (errorMessage.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: .2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.withValues(alpha: .4)),
                                  ),
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],

                              if (connected && chosenDevice != null) ...[
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .22),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.4,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.memory, color: Colors.white.withValues(alpha: .95)),
                                      const SizedBox(width: 10),
                                      Text(
                                        chosenDevice!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),

                              if (!connected)
                                FilledButton.icon(
                                  onPressed: scanning ? null : _startScanAndConnect,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: const StadiumBorder(),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  ),
                                  icon: const Icon(Icons.search),
                                  label: const Text('Buscar y Conectar'),
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
                            // badge "!"
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
                                        : 'Enciende tu Arduino (GuitaBLE), acércalo al teléfono y presiona "Buscar y Conectar".',
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
