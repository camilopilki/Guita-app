import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'ble_config.dart';

class BleService {
  static final BleService _instance = BleService._internal();
  factory BleService() => _instance;
  BleService._internal();

  // Plugin BLE principal
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  // Estado de conexión
  bool isConnected = false;

  // Device conectado
  DiscoveredDevice? _connectedDevice;

  // Suscripción al stream de conexión
  StreamSubscription<ConnectionStateUpdate>? _connectionSub;

  // Suscripción a notificaciones
  StreamSubscription<List<int>>? _notifySub;

  // Características BLE
  QualifiedCharacteristic? _notifyChar;
  QualifiedCharacteristic? _writeChar;

  // Stream que expone los datos como texto
  final StreamController<String> _dataController = StreamController.broadcast();
  Stream<String> get dataStream => _dataController.stream;

  // Stream que expone el estado de conexión
  final StreamController<bool> _connectionStateController = StreamController.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  // Stream que parsea los datos del sensor a un mapa
  final StreamController<Map<String, dynamic>> _sensorDataController = StreamController.broadcast();
  Stream<Map<String, dynamic>> get sensorDataStream => _sensorDataController.stream;

  // =====================================================
  // 1) Escanear y Conectar
  // =====================================================
  Future<void> scanAndConnect() async {
    print("🔍 Escaneando dispositivos BLE…");

    final completer = Completer<void>();

    // Declaración de scanSub
    late StreamSubscription<DiscoveredDevice> scanSub;

    final stream = _ble.scanForDevices(
      withServices: [], // escanea todo
      scanMode: ScanMode.lowLatency,
    );

    scanSub = stream.listen((device) async {
      print("📡 Encontrado: ${device.name} - ${device.id}");

      if (device.name == "GuitaBLE") {
        print("🎯 ¡GuitaBLE detectado!");

        await scanSub.cancel(); // Detenemos el escaneo
        _connectedDevice = device;

        // Iniciar conexión
        _connectionSub = _ble
            .connectToDevice(
              id: device.id,
              servicesWithCharacteristicsToDiscover: {
                Uuid.parse(BleConfig.serviceUuid): [
                  Uuid.parse(BleConfig.dataCharUuid),
                  Uuid.parse(BleConfig.resetCharUuid),
                ]
              },
              connectionTimeout: const Duration(seconds: 6),
            )
            .listen((state) async {
          print("🔗 Estado conexión: ${state.connectionState}");

          if (state.connectionState == DeviceConnectionState.connected) {
            print("✅ Conectado a GuitaBLE");

            isConnected = true;
            _connectionStateController.add(true);

            _notifyChar = QualifiedCharacteristic(
              deviceId: device.id,
              serviceId: Uuid.parse(BleConfig.serviceUuid),
              characteristicId: Uuid.parse(BleConfig.dataCharUuid),
            );

            _writeChar = QualifiedCharacteristic(
              deviceId: device.id,
              serviceId: Uuid.parse(BleConfig.serviceUuid),
              characteristicId: Uuid.parse(BleConfig.resetCharUuid),
            );

            await _startNotifications();

            if (!completer.isCompleted) {
              completer.complete();
            }
          }

          if (state.connectionState == DeviceConnectionState.disconnected) {
            print("❌ Desconectado");

            isConnected = false;
            _connectionStateController.add(false);

            // Limpiar
            _connectedDevice = null;
            _notifyChar = null;
            _writeChar = null;

            if (!completer.isCompleted) {
              completer.completeError("Error: desconectado");
            }
          }
        });
      }
    });

    return completer.future;
  }

  // =====================================================
  // 2) Iniciar Notificaciones — Recibir datos
  // =====================================================
  Future<void> _startNotifications() async {
    if (_notifyChar == null) {
      return;
    }

    print("📨 Activando notificaciones…");

    _notifySub = _ble
        .subscribeToCharacteristic(_notifyChar!)
        .listen((data) {
      try {
        final text = String.fromCharCodes(data);
        _dataController.add(text);
        
        try {
          final cleanText = text.trim();
          final flowRate = double.tryParse(cleanText) ?? 0.0;
          
          _sensorDataController.add({
            'flowRate': flowRate,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        } catch (e) {
          // Error parseando datos
        }
      } catch (e) {
        // Error procesando notificación
      }
    });
  }

  // =====================================================
  // 3) Enviar comando RESET (opcional)
  // =====================================================
  Future<void> sendResetCommand() async {
    if (!isConnected || _writeChar == null) {
      print("⚠️ No se puede enviar RESET: no conectado");
      return;
    }

    try {
      print("🔄 Enviando comando RESET al Arduino…");
      await _ble.writeCharacteristicWithResponse(
        _writeChar!,
        value: [1], // bandera "1"
      );
      print("🟢 RESET enviado");
    } catch (e) {
      print("❌ Error enviando RESET: $e");
    }
  }

  // =====================================================
  // 4) Desconectar correctamente
  // =====================================================
  Future<void> disconnect() async {
    print("🔌 Forzando desconexión…");

    try {
      await _notifySub?.cancel();
    } catch (_) {}

    try {
      await _connectionSub?.cancel();
    } catch (_) {}

    _connectedDevice = null;
    _notifyChar = null;
    _writeChar = null;
    isConnected = false;
    
    _connectionStateController.add(false);

    print("🟢 BLE limpiado y desconectado.");
  }

  void dispose() {
    _dataController.close();
    _sensorDataController.close();
    _connectionStateController.close();
  }
}
