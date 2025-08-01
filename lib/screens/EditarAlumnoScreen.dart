import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../models/alumno.dart';
import '../widgets/formulario_alumno_widget.dart';
import '../db/database_helper.dart';

class EditarAlumnoScreen extends StatefulWidget {
  final Grupo grupo;
  final Alumno alumno;

  EditarAlumnoScreen({required this.grupo, required this.alumno});

  @override
  _EditarAlumnoScreenState createState() => _EditarAlumnoScreenState();
}

class _EditarAlumnoScreenState extends State<EditarAlumnoScreen> {
  void eliminarAlumno() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('¿Eliminar alumno?'),
            content: Text(
              '¿Estás seguro de eliminar a "${widget.alumno.nombreCompleto}"? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      await DatabaseHelper().eliminarAlumno(widget.alumno.id);
      Navigator.pop(context); // Cierra pantalla actual
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Alumno eliminado correctamente')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Alumno'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            tooltip: 'Eliminar alumno',
            onPressed: eliminarAlumno,
          ),
        ],
      ),
      body: Stack(
        children: [
          FormularioAlumnoWidget(
            grupoId: widget.grupo.id,
            alumnoInicial: widget.alumno,
            onGuardado: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Alumno actualizado')));
            },
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              '🧪 Hola desde edición',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Botón de prueba presionado')));
        },
        child: Icon(Icons.build),
        tooltip: 'Prueba',
      ),
    );
  }
}
