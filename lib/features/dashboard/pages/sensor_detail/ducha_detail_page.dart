import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../ble/ble_service.dart';

class DuchaDetailPage extends StatefulWidget {
  const DuchaDetailPage({super.key});

  @override
  State<DuchaDetailPage> createState() => _DuchaDetailPageState();
}

class _DuchaDetailPageState extends State<DuchaDetailPage> {
  static const _assetMascota = 'assets/images/normal.png';
  static const _assetPanel = 'assets/images/ducha.png';

  final BleService _bleService = BleService();
  
  StreamSubscription<Map<String, dynamic>>? _dataSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  
  // Variables para almacenar datos del sensor
  double _litrosHoy = 0.0;
  double _litrosSemana = 0.0;
  double _litrosMes = 0.0;
  double _litrosTotal = 780.0;
  
  double _flujoActual = 0.0;
  bool _isConnected = false;
  
  DateTime? _lastReadingTime;

  @override
  void initState() {
    super.initState();
    _isConnected = _bleService.isConnected;
    _listenToConnectionState();
    _listenToSensorData();
  }

  void _listenToConnectionState() {
    _connectionSubscription = _bleService.connectionStateStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });
  }

  void _listenToSensorData() {
    _dataSubscription = _bleService.sensorDataStream.listen((data) {
      print("[v0] Datos recibidos del stream: $data");
      
      if (mounted) {
        setState(() {
          _flujoActual = data['flowRate'] ?? 0.0;
          
          print("[v0] Flujo actual: $_flujoActual mL/s");
          
          if (_flujoActual > 0) {
            final now = DateTime.now();
            
            if (_lastReadingTime != null) {
              // Calcular segundos transcurridos desde la ultima lectura
              final secondsElapsed = now.difference(_lastReadingTime!).inMilliseconds / 1000.0;
              
              print("[v0] Segundos transcurridos: $secondsElapsed");
              
              // Convertir: flujo (mL/s) * tiempo (s) = mL totales
              // Luego dividir entre 1000 para convertir a litros
              double litrosEnEstaLectura = (_flujoActual * secondsElapsed) / 1000.0;
              
              print("[v0] Litros en esta lectura: $litrosEnEstaLectura");
              
              _litrosHoy += litrosEnEstaLectura;
              _litrosSemana = _litrosHoy;
              _litrosMes = _litrosSemana;
              _litrosTotal += litrosEnEstaLectura;
              
              print("[v0] Litros HOY acumulados: $_litrosHoy");
            } else {
              print("[v0] Primera lectura con flujo, inicializando temporizador");
            }
            
            _lastReadingTime = now;
          } else {
            // Si no hay flujo, reiniciar el temporizador
            _lastReadingTime = null;
          }
        });
      }
    }, onError: (error) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }, onDone: () {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _connectionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF233E8B);
    const lightBlue = Color(0xFF5C77F2);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: lightBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'DUCHA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ===== HEADER =====
            Container(
              width: double.infinity,
              height: 360,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [lightBlue, Color(0xFF91B1FF)],
                ),
              ),
              child: Align(
                alignment: const Alignment(0, 0.35),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Ahorro de litros',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .6,
                        shadows: [
                          Shadow(
                            color: Color(0x33000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _MascotaSticker(
                      assetPath: _assetMascota,
                      size: 136,
                      zoomCrop: 0.72,
                      panXPct: 0.12,
                    ),
                    const SizedBox(height: 10),
                    _BigNumber(value: _litrosTotal, unit: 'L'),
                  ],
                ),
              ),
            ),

            // ===== PANEL =====
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 400),
              margin: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
              padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'HOY',
                        style: TextStyle(
                          color: blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Text(
                        '${_litrosHoy.toStringAsFixed(1)} L',
                        style: const TextStyle(
                          color: blue,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Image.asset(_assetPanel, width: 118, height: 118),
                  const SizedBox(height: 30),
                  _DataBadge(
                    title: 'ESTA SEMANA',
                    value: '${_litrosSemana.toStringAsFixed(1)} L',
                  ),
                  const SizedBox(height: 16),
                  _DataBadge(
                    title: 'ESTE MES',
                    value: '${_litrosMes.toStringAsFixed(1)} L',
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _isConnected
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isConnected ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                          color: _isConnected ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isConnected
                              ? 'Flujo: ${_flujoActual.toStringAsFixed(1)} mL/s'
                              : 'Desconectado',
                          style: TextStyle(
                            color: _isConnected ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===== Widgets internos ===== */
class _BigNumber extends StatelessWidget {
  const _BigNumber({required this.value, required this.unit});
  final num value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final s = value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: s,
            style: const TextStyle(
              fontSize: 44,
              height: 1.0,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Color(0x33000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          TextSpan(
            text: ' $unit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: .95),
            ),
          ),
        ],
      ),
    );
  }
}

class _MascotaSticker extends StatelessWidget {
  const _MascotaSticker({
    required this.assetPath,
    required this.size,
    this.zoomCrop = 0.74,
    this.panXPct = 0.12,
  });

  final String assetPath;
  final double size;
  final double zoomCrop;
  final double panXPct;

  @override
  Widget build(BuildContext context) {
    final w = size;
    return SizedBox(
      width: w,
      height: w,
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
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DataBadge extends StatelessWidget {
  final String title;
  final String value;

  const _DataBadge({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF233E8B);
    const lightBg = Color(0xFFEFF3FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lightBg,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: blue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: .6,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: blue,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }
}
