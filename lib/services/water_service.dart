import 'package:supabase_flutter/supabase_flutter.dart';

class WaterService {
  // Cliente de Supabase
  final supabase = Supabase.instance.client;

  /// ================================
  /// ENVÍA UNA LECTURA A SUPABASE
  /// ================================
  Future<void> enviarLectura({
    required String dispositivoId,
    required double flujoLMin,
    required double deltaLitros,
    required double totalLitros,
  }) async {
    try {
      await supabase.from('lecturas_agua').insert({
        'dispositivo_id': dispositivoId,
        'flujo_l_min': flujoLMin,
        'volumen_delta_l': deltaLitros,
        'volumen_total_l': totalLitros,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error enviando lectura: $e');
    }
  }

  /// ================================
  /// OBTIENE TODAS LAS LECTURAS
  /// ================================
  Future<List<Map<String, dynamic>>> obtenerLecturas({
    required String dispositivoId,
  }) async {
    try {
      final data = await supabase
          .from('lecturas_agua')
          .select()
          .eq('dispositivo_id', dispositivoId)
          .order('timestamp', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error obteniendo lecturas: $e');
    }
  }

  /// =======================================
  /// OBTENER ÚLTIMA LECTURA
  /// =======================================
  Future<Map<String, dynamic>?> obtenerUltimaLectura({
    required String dispositivoId,
  }) async {
    try {
      final data = await supabase
          .from('lecturas_agua')
          .select()
          .eq('dispositivo_id', dispositivoId)
          .order('timestamp', ascending: false)
          .limit(1);

      if (data.isEmpty) return null;
      return Map<String, dynamic>.from(data.first);
    } catch (e) {
      throw Exception('Error obteniendo última lectura: $e');
    }
  }

  /// =======================================================
  /// ENVÍA LECTURAS SIMULADAS (mientras esperamos el BLE)
  /// =======================================================
  Future<void> enviarLecturaSimulada({
    required String dispositivoId,
  }) async {
    final ultima = await obtenerUltimaLectura(dispositivoId: dispositivoId);

    double totalPrevio = ultima?['volumen_total_l']?.toDouble() ?? 0.0;

    final flujo = (1 + (4 * (DateTime.now().millisecond / 1000)));
    final delta = flujo / 60; // flujo L / minuto → convertir a litro por segundo
    final totalNuevo = totalPrevio + delta;

    await enviarLectura(
      dispositivoId: dispositivoId,
      flujoLMin: flujo,
      deltaLitros: delta,
      totalLitros: totalNuevo,
    );
  }

  /// =======================================================
  /// RESUMEN: HOY, SEMANA, MES Y TOTAL (PARA MOSTRAR EN UI)
  /// =======================================================
  Future<Map<String, double>> obtenerResumen(String dispositivoId) async {
    double sum(List data) =>
        data.fold(0.0, (prev, row) => prev + (row['volumen_delta_l'] ?? 0));

    // HOY (desde medianoche)
    final hoyData = await supabase
        .from('lecturas_agua')
        .select('volumen_delta_l')
        .eq('dispositivo_id', dispositivoId)
        .gte(
          'timestamp',
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .toIso8601String(),
        );

    // SEMANA (desde el lunes)
    final monday = DateTime.now()
        .subtract(Duration(days: DateTime.now().weekday - 1));

    final semanaData = await supabase
        .from('lecturas_agua')
        .select('volumen_delta_l')
        .eq('dispositivo_id', dispositivoId)
        .gte('timestamp', monday.toIso8601String());

    // MES (desde el día 1)
    final mesData = await supabase
        .from('lecturas_agua')
        .select('volumen_delta_l')
        .eq('dispositivo_id', dispositivoId)
        .gte(
          'timestamp',
          DateTime(DateTime.now().year, DateTime.now().month, 1)
              .toIso8601String(),
        );

    // TOTAL (último valor registrado)
    final totalRow = await supabase
        .from('lecturas_agua')
        .select('volumen_total_l')
        .eq('dispositivo_id', dispositivoId)
        .order('timestamp', ascending: false)
        .limit(1);

    double total = totalRow.isEmpty
        ? 0.0
        : (totalRow.first['volumen_total_l'] ?? 0.0).toDouble();

    return {
      'hoy': sum(hoyData),
      'semana': sum(semanaData),
      'mes': sum(mesData),
      'total': total,
    };
  }
}
