import 'package:flutter/material.dart';
import '../models/alumno.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';

class FormularioAlumnoWidget extends StatefulWidget {
  final String grupoId;
  final Alumno? alumnoInicial;
  final Function()? onGuardado;

  FormularioAlumnoWidget({
    required this.grupoId,
    this.alumnoInicial,
    this.onGuardado,
  });

  @override
  _FormularioAlumnoWidgetState createState() => _FormularioAlumnoWidgetState();
}

class _FormularioAlumnoWidgetState extends State<FormularioAlumnoWidget> {
  final _formKey = GlobalKey<FormState>();
  late String nombres;
  late String apellidos;
  late int edad;
  DateTime? fechaNacimiento;
  String? genero;

  @override
  void initState() {
    super.initState();
    final alumno = widget.alumnoInicial;
    nombres = alumno?.nombres ?? '';
    apellidos = alumno?.apellidos ?? '';
    edad = alumno?.edad ?? 0;
    genero = alumno?.genero;
    fechaNacimiento = alumno?.fechaNacimiento;
  }

  Future<void> eliminarAlumnoDesdeFormulario() async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('¿Eliminar alumno?'),
            content: Text(
              '¿Deseas eliminar a "${widget.alumnoInicial?.nombreCompleto}"? Esta acción no se puede deshacer.',
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
      await DatabaseHelper().eliminarAlumno(widget.alumnoInicial!.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Alumno eliminado correctamente')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.alumnoInicial != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            campoTexto(
              label: 'Apellido(s)',
              icono: Icons.badge,
              inicial: apellidos,
              onChanged: (value) => apellidos = value,
            ),
            SizedBox(height: 12),
            campoTexto(
              label: 'Nombre(s)',
              icono: Icons.person,
              inicial: nombres,
              onChanged: (value) => nombres = value,
            ),
            SizedBox(height: 12),
            campoNumerico(
              label: 'Edad',
              icono: Icons.cake,
              inicial: edad > 0 ? edad.toString() : '',
              onChanged: (value) => edad = int.tryParse(value) ?? 0,
              validator: (value) {
                final n = int.tryParse(value ?? '');
                if (n == null || n <= 0) {
                  return 'Edad inválida';
                }
                return null;
              },
            ),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text(
                fechaNacimiento == null
                    ? 'Seleccionar fecha de nacimiento'
                    : DateFormat('yyyy-MM-dd').format(fechaNacimiento!),
              ),
              onTap: () async {
                final seleccionada = await showDatePicker(
                  context: context,
                  initialDate: fechaNacimiento ?? DateTime(2010),
                  firstDate: DateTime(1995),
                  lastDate: DateTime.now(),
                );
                if (seleccionada != null) {
                  setState(() {
                    fechaNacimiento = seleccionada;
                  });
                }
              },
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: genero,
              decoration: InputDecoration(
                labelText: 'Género',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
              ],
              onChanged: (value) => genero = value,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Selecciona un género'
                          : null,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(esEdicion ? Icons.save : Icons.add),
              label: Text(esEdicion ? 'Guardar cambios' : 'Agregar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (fechaNacimiento == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selecciona la fecha de nacimiento'),
                      ),
                    );
                    return;
                  }

                  final db = DatabaseHelper();
                  final nuevoAlumno = Alumno(
                    id:
                        widget.alumnoInicial?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    nombres: nombres.trim(),
                    apellidos: apellidos.trim(),
                    edad: edad,
                    fechaNacimiento: fechaNacimiento!, // ✅ DateTime directo
                    genero: genero!,
                    grupoId: widget.grupoId,
                  );

                  if (esEdicion) {
                    await db.updateAlumno(nuevoAlumno);
                  } else {
                    await db.insertAlumno(nuevoAlumno);
                  }

                  // Reordenar después de guardar
                  final listaActualizada = await db.getAlumnosPorGrupo(
                    widget.grupoId,
                  );
                  listaActualizada.sort(
                    (a, b) => a.apellidos.toLowerCase().compareTo(
                      b.apellidos.toLowerCase(),
                    ),
                  );
                  for (int i = 0; i < listaActualizada.length; i++) {
                    listaActualizada[i].numeroLista = i + 1;
                    await db.updateAlumno(listaActualizada[i]);
                  }

                  widget.onGuardado?.call();
                  Navigator.pop(context);
                }
              },
            ),
            if (esEdicion) ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                icon: Icon(Icons.delete, color: Colors.white),
                label: Text(
                  'Eliminar alumno',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: eliminarAlumnoDesdeFormulario,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget campoTexto({
    required String label,
    required IconData icono,
    required String inicial,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      initialValue: inicial,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator:
          (value) =>
              value == null || value.trim().isEmpty
                  ? 'Campo obligatorio'
                  : null,
    );
  }

  Widget campoNumerico({
    required String label,
    required IconData icono,
    required String inicial,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: inicial,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono),
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
