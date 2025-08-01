import 'package:excel/excel.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/alumno.dart';
import '../models/grupo.dart';
import '../db/database_helper.dart';

class ExcelExporter {
  // 🧾 Exportación desde DetalleGrupoScreen (sin asistencia)
  static Future<String> exportarAsistenciaDeGrupo(Grupo grupo) async {
    final alumnos = await DatabaseHelper().getAlumnosPorGrupo(grupo.id);
    final excel = Excel.createExcel();
    final hoja = excel['Lista de Alumnos'];

    hoja.appendRow(['Número', 'Apellido(s)', 'Nombre(s)', 'Edad', 'Género']);

    for (var alumno in alumnos) {
      hoja.appendRow([
        alumno.numeroLista,
        alumno.apellidos,
        alumno.nombres,
        alumno.edad,
        alumno.genero,
      ]);
    }

    final nombreArchivo =
        'Lista_${grupo.nombre.replaceAll(" ", "_")}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    final directorio = Directory('/storage/emulated/0/Download');
    if (!await directorio.exists()) {
      await directorio.create(recursive: true);
    }

    final archivo = File('${directorio.path}/$nombreArchivo')
      ..createSync(recursive: true);
    archivo.writeAsBytesSync(excel.encode()!);

    return archivo.path;
  }

  // 🗓️ Exportación desde PaseListaScreen (con asistencia del día)
  static Future<String> exportarAsistenciaPorDia({
    required Grupo grupo,
    required DateTime fecha,
    required List<Alumno> alumnos,
    required Map<String, String> estados,
  }) async {
    final excel = Excel.createExcel();
    final hoja = excel['Asistencia'];

    hoja.appendRow([
      'Número',
      'Apellido(s)',
      'Nombre(s)',
      'Edad',
      'Género',
      'Estado de asistencia',
      'Fecha',
    ]);

    final fechaFormateada = DateFormat('yyyy-MM-dd').format(fecha);

    for (var alumno in alumnos) {
      hoja.appendRow([
        alumno.numeroLista,
        alumno.apellidos,
        alumno.nombres,
        alumno.edad,
        alumno.genero,
        estados[alumno.id] ?? '—',
        fechaFormateada,
      ]);
    }

    final nombreArchivo =
        'Asistencia_${grupo.nombre.replaceAll(" ", "_")}_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    final directorio = Directory('/storage/emulated/0/Download');
    if (!await directorio.exists()) {
      await directorio.create(recursive: true);
    }

    final archivo = File('${directorio.path}/$nombreArchivo')
      ..createSync(recursive: true);
    archivo.writeAsBytesSync(excel.encode()!);

    return archivo.path;
  }
}
