class BleConfig {
  /// UUID del servicio principal del sensor
  static const String serviceUuid = "19b10000-e8f2-537e-4f6c-d104768a1214";

  /// Característica que envía datos desde el Arduino a la app (NOTIFY + READ)
  static const String dataCharUuid = "19b10001-e8f2-537e-4f6c-d104768a1214";

  /// Característica para enviar comandos desde la app al Arduino (WRITE)
  static const String resetCharUuid = "19b10002-e8f2-537e-4f6c-d104768a1214";
}
