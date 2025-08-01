import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../models/alumno.dart';
import '../widgets/formulario_alumno_widget.dart';

class EditarAlumnoScreen extends StatelessWidget {
  final Grupo grupo;
  final Alumno alumno;

  EditarAlumnoScreen({required this.grupo, required this.alumno});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Alumno')),
      body: FormularioAlumnoWidget(
        grupoId: grupo.id,
        alumnoInicial: alumno,
        onGuardado: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Alumno actualizado correctamente')),
          );
        },
      ),
    );
  }
}
