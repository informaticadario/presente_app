import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/grupo.dart';
import '../models/alumno.dart';
import '../db/database_helper.dart';
import '../utils/excel_exporter.dart';
import 'package:google_fonts/google_fonts.dart';

class PaseListaScreen extends StatefulWidget {
  final Grupo grupo;

  PaseListaScreen({required this.grupo});

  @override
  _PaseListaScreenState createState() => _PaseListaScreenState();
}

class _PaseListaScreenState extends State<PaseListaScreen> {
  List<Alumno> alumnos = [];
  Map<String, String> estadosPorDia = {};
  DateTime fechaSeleccionada = DateTime.now();
  bool asistenciaGuardada = false;

  @override
  void initState() {
    super.initState();
    cargarAsistenciaDelDia();
  }

  Future<void> cargarAsistenciaDelDia() async {
    final todos = await DatabaseHelper().getAlumnosPorGrupo(widget.grupo.id);
    final fecha = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
    final db = await DatabaseHelper().database;

    final registros = await db.query(
      'asistencias_por_dia',
      where: 'grupoId = ? AND fecha = ?',
      whereArgs: [widget.grupo.id, fecha],
    );

    Map<String, String> estados = {
      for (var fila in registros)
        fila['alumnoId'] as String: fila['estado'] as String,
    };

    setState(() {
      alumnos = todos;
      estadosPorDia = estados;
      asistenciaGuardada = registros.isNotEmpty;
    });
  }

  Future<void> guardarPaseDeLista() async {
    final fecha = DateFormat('yyyy-MM-dd').format(fechaSeleccionada);
    final db = DatabaseHelper();
    final yaExiste = await db.existeAsistenciaDelGrupo(widget.grupo.id, fecha);

    if (yaExiste) {
      final confirmar = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('¿Sobrescribir asistencia?'),
              content: Text(
                'Ya existe un pase de lista guardado para esta fecha. ¿Quieres sobrescribirlo?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Sí, guardar'),
                ),
              ],
            ),
      );
      if (confirmar != true) return;
    }

    for (var alumno in alumnos) {
      final estado = estadosPorDia[alumno.id] ?? 'Sin marcar';
      await db.registrarAsistenciaPorDia(
        alumnoId: alumno.id,
        grupoId: widget.grupo.id,
        estado: estado,
        fecha: fecha,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pase de lista guardado para $fecha')),
    );
    await cargarAsistenciaDelDia();
  }

  void cambiarEstado(String alumnoId, String estado) {
    final estadoActual = estadosPorDia[alumnoId] ?? 'Sin marcar';
    if (estadoActual != estado) {
      setState(() {
        estadosPorDia[alumnoId] = estado;
        asistenciaGuardada = false;
      });
    }
  }

  Future<void> exportarAsistenciaDelDia() async {
    final ruta = await ExcelExporter.exportarAsistenciaPorDia(
      grupo: widget.grupo,
      fecha: fechaSeleccionada,
      alumnos: alumnos,
      estados: estadosPorDia,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Archivo guardado en Descargas 📁')));
  }

  Widget encabezadoFecha() {
    final textoFecha = DateFormat(
      'd MMMM yyyy',
      'es_MX',
    ).format(fechaSeleccionada);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                textoFecha,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.edit_calendar, color: Colors.black87),
            onPressed: () async {
              final seleccionada = await showDatePicker(
                context: context,
                initialDate: fechaSeleccionada,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (seleccionada != null) {
                setState(() {
                  fechaSeleccionada = seleccionada;
                });
                await cargarAsistenciaDelDia();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget resumenAsistencia() {
    final total = alumnos.length;
    int presentes = 0, ausentes = 0, retardos = 0;

    estadosPorDia.forEach((_, estado) {
      switch (estado) {
        case 'Presente':
          presentes++;
          break;
        case 'Ausente':
          ausentes++;
          break;
        case 'Retardo':
          retardos++;
          break;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          columnaResumen(Icons.group, total, Colors.grey[700]),
          columnaResumen(Icons.check_circle, presentes, Colors.green[700]),
          columnaResumen(Icons.cancel, ausentes, Colors.red[700]),
          columnaResumen(Icons.access_time, retardos, Colors.orange[700]),
        ],
      ),
    );
  }

  Widget columnaResumen(IconData icono, int valor, Color? color) {
    return Column(
      children: [
        Icon(icono, color: color, size: 22),
        SizedBox(height: 2),
        Text(
          '$valor',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget tarjetaAlumno(Alumno alumno) {
    final estado = estadosPorDia[alumno.id] ?? 'Sin marcar';
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFF007EA7),
                  child: Text('${alumno.numeroLista}'),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    alumno.nombreCompleto,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estado: $estado',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        color:
                            estado == 'Presente' ? Colors.green : Colors.grey,
                      ),
                      tooltip: 'Presente',
                      onPressed: () => cambiarEstado(alumno.id, 'Presente'),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.access_time,
                        color:
                            estado == 'Retardo' ? Colors.orange : Colors.grey,
                      ),
                      tooltip: 'Retardo',
                      onPressed: () => cambiarEstado(alumno.id, 'Retardo'),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.cancel,
                        color: estado == 'Ausente' ? Colors.red : Colors.grey,
                      ),
                      tooltip: 'Ausente',
                      onPressed: () => cambiarEstado(alumno.id, 'Ausente'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pase de lista - ${widget.grupo.nombre}'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'exportar') {
                exportarAsistenciaDelDia();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'exportar',
                    child: Text(
                      'Exportar asistencia 📄',
                      style: GoogleFonts.robotoSlab(fontSize: 14),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Column(
        children: [
          encabezadoFecha(),
          resumenAsistencia(),
          Expanded(
            child:
                alumnos.isEmpty
                    ? Center(child: Text('No hay alumnos registrados'))
                    : ListView.builder(
                      itemCount: alumnos.length,
                      itemBuilder: (context, index) {
                        return tarjetaAlumno(alumnos[index]);
                      },
                    ),
          ),
          SafeArea(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text(
                  asistenciaGuardada ? 'Guardado ✔️' : 'Guardar pase de lista',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF80C5DB),
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: asistenciaGuardada ? null : guardarPaseDeLista,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
