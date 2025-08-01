import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import '../models/grupo.dart';
import '../models/alumno.dart';
import 'agregar_alumno_screen.dart';
import 'editar_alumno_screen.dart';
import 'pase_lista_screen.dart';
import '../db/database_helper.dart';
import '../utils/excel_exporter.dart';
import 'package:google_fonts/google_fonts.dart';

class DetalleGrupoScreen extends StatefulWidget {
  final Grupo grupo;
  DetalleGrupoScreen({required this.grupo});
  @override
  _DetalleGrupoScreenState createState() => _DetalleGrupoScreenState();
}

class _DetalleGrupoScreenState extends State<DetalleGrupoScreen> {
  List<Alumno> alumnos = [];
  bool ordenAscendente = true;

  @override
  void initState() {
    super.initState();
    cargarAlumnos();
  }

  Future<void> cargarAlumnos() async {
    final lista = await DatabaseHelper().getAlumnosPorGrupo(widget.grupo.id);

    // Ordenar por apellidos y reasignar número de lista
    lista.sort((a, b) => a.apellidos.compareTo(b.apellidos));
    for (int i = 0; i < lista.length; i++) {
      lista[i].numeroLista = i + 1;
      await DatabaseHelper().updateNumeroLista(
        lista[i].id,
        lista[i].numeroLista,
      );
    }

    setState(() {
      alumnos = List.from(lista);
      ordenarAlumnos();
    });
  }

  void ordenarAlumnos() {
    alumnos.sort(
      (a, b) =>
          ordenAscendente
              ? a.numeroLista.compareTo(b.numeroLista)
              : b.numeroLista.compareTo(a.numeroLista),
    );
  }

  void cambiarOrden() {
    setState(() {
      ordenAscendente = !ordenAscendente;
      ordenarAlumnos();
    });
  }

  void abrirAgregarAlumno() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AgregarAlumnoScreen(grupo: widget.grupo),
      ),
    ).then((_) => cargarAlumnos());
  }

  void abrirPaseDeLista() async {
    final recargado = await DatabaseHelper().getGrupos().then(
      (grupos) => grupos.firstWhere(
        (g) => g.id == widget.grupo.id,
        orElse: () => widget.grupo,
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaseListaScreen(grupo: recargado)),
    ).then((_) => cargarAlumnos());
  }

  void abrirEditorAlumno(Alumno alumno) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditarAlumnoScreen(grupo: widget.grupo, alumno: alumno),
      ),
    ).then((_) => cargarAlumnos());
  }

  void exportarExcel() async {
    final ruta = await ExcelExporter.exportarAsistenciaDeGrupo(widget.grupo);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Archivo Excel guardado: $ruta',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Future<void> eliminarTodosLosAlumnos() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              '¿Eliminar todos los alumnos?',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            content: Text(
              'Esta acción borrará todos los alumnos de este grupo y no se puede deshacer.',
            ),
            actions: [
              TextButton(
                child: Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      await DatabaseHelper().deleteAlumnosPorGrupo(widget.grupo.id);
      await cargarAlumnos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Se eliminaron todos los alumnos 🗑️')),
      );
    }
  }

  Future<void> importarDesdeExcelConDialog() async {
    final archivoPath = await FlutterFileDialog.pickFile(
      params: OpenFileDialogParams(
        dialogType: OpenFileDialogType.document,
        fileExtensionsFilter: ['xlsx'],
      ),
    );
    if (archivoPath == null) return;

    final bytes = await File(archivoPath).readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    final hoja = excel.tables.values.first;
    final filas = hoja?.rows ?? [];

    List<Alumno> alumnosTemp = [];

    for (var fila in filas.skip(1)) {
      if (fila.every((c) => c?.value == null)) continue;
      if (fila.length < 5) continue;

      final apellidos = fila[0]?.value;
      final nombres = fila[1]?.value;
      final edad = int.tryParse(fila[2]?.value.toString() ?? '') ?? 0;
      final genero = fila[3]?.value;
      final fechaStr = fila[4]?.value?.toString();

      if (apellidos == null || nombres == null) continue;

      DateTime fechaNacimiento;
      try {
        fechaNacimiento = DateTime.parse(fechaStr!);
      } catch (_) {
        try {
          fechaNacimiento = DateFormat('dd-MM-yyyy').parse(fechaStr!);
        } catch (_) {
          try {
            fechaNacimiento = DateFormat('MM/dd/yyyy').parse(fechaStr!);
          } catch (_) {
            fechaNacimiento = DateTime(2000, 1, 1);
          }
        }
      }

      final alumno = Alumno(
        id: UniqueKey().toString(),
        grupoId: widget.grupo.id,
        numeroLista: 0,
        apellidos: apellidos.toString(),
        nombres: nombres.toString(),
        edad: edad,
        genero: genero.toString(),
        fechaNacimiento: fechaNacimiento,
      );

      alumnosTemp.add(alumno);
    }

    alumnosTemp.sort((a, b) => a.apellidos.compareTo(b.apellidos));
    for (int i = 0; i < alumnosTemp.length; i++) {
      alumnosTemp[i].numeroLista = i + 1;
      await DatabaseHelper().insertAlumno(alumnosTemp[i]);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Se importaron ${alumnosTemp.length} alumnos correctamente 📥',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );

    await cargarAlumnos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grupo.nombre),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'pase':
                  abrirPaseDeLista();
                  break;
                case 'agregar':
                  abrirAgregarAlumno();
                  break;
                case 'ordenar':
                  cambiarOrden();
                  break;
                case 'exportar':
                  exportarExcel();
                  break;
                case 'importar':
                  importarDesdeExcelConDialog();
                  break;
                case 'eliminar_todos':
                  await eliminarTodosLosAlumnos();
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'pase',
                    child: Text(
                      'Pase de Lista',
                      style: GoogleFonts.robotoSlab(fontSize: 14),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'agregar',
                    child: Text(
                      'Agregar Alumno',
                      style: GoogleFonts.robotoSlab(fontSize: 14),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ordenar',
                    child: Text(
                      ordenAscendente
                          ? 'Ordenar descendente'
                          : 'Ordenar ascendente',
                      style: GoogleFonts.robotoSlab(fontSize: 14),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'exportar',
                    child: Text(
                      'Exportar Excel 📤',
                      style: GoogleFonts.robotoSlab(fontSize: 14),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'importar',
                    child: Text(
                      'Importar desde Excel 📥',
                      style: GoogleFonts.robotoSlab(fontSize: 14),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'eliminar_todos',
                    child: Text(
                      'Eliminar todos los alumnos 🗑️',
                      style: GoogleFonts.robotoSlab(fontSize: 14),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body:
          alumnos.isEmpty
              ? Center(child: Text('No hay alumnos registrados'))
              : ListView.builder(
                itemCount: alumnos.length,
                itemBuilder: (context, index) {
                  final alumno = alumnos[index];
                  final avatarPath =
                      alumno.genero == 'Masculino'
                          ? 'assets/images/avatar_male.png'
                          : 'assets/images/avatar_female.png';

                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Color(0xFF007EA7),
                        child: Text('${alumno.numeroLista}'),
                      ),
                      title: Text(
                        alumno.nombreCompleto,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            avatarPath,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.black87,
                            ),
                            tooltip: 'Editar alumno',
                            onPressed: () => abrirEditorAlumno(alumno),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
