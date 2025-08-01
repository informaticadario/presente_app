import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../models/alumno.dart';
import '../db/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class AgregarAlumnoScreen extends StatefulWidget {
  final Grupo grupo;

  AgregarAlumnoScreen({required this.grupo});

  @override
  _AgregarAlumnoScreenState createState() => _AgregarAlumnoScreenState();
}

class _AgregarAlumnoScreenState extends State<AgregarAlumnoScreen> {
  final _formKey = GlobalKey<FormState>();

  String nombres = '';
  String apellidos = '';
  int edad = 0;
  DateTime? fechaNacimiento;
  String? genero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar Alumno')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              campoTexto(
                label: 'Apellido(s)',
                icono: Icons.badge,
                onChanged: (value) => apellidos = value,
              ),
              SizedBox(height: 12),
              campoTexto(
                label: 'Nombre(s)',
                icono: Icons.person,
                onChanged: (value) => nombres = value,
              ),
              SizedBox(height: 12),
              campoNumerico(
                label: 'Edad',
                icono: Icons.cake,
                onChanged: (value) => edad = int.tryParse(value) ?? 0,
              ),
              SizedBox(height: 12),
              ListTile(
                leading: Icon(Icons.calendar_today),
                title: Text(
                  fechaNacimiento == null
                      ? 'Seleccionar fecha de nacimiento'
                      : DateFormat('yyyy-MM-dd').format(fechaNacimiento!),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  final seleccionada = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2010),
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
                decoration: InputDecoration(
                  labelText: 'Género',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                  prefixIcon: Icon(
                    Icons.person_2_outlined,
                    color: const Color(0xFF007EA7),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F8FC), // fondo suave
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Masculino',
                    child: Text(
                      'Masculino',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Femenino',
                    child: Text(
                      'Femenino',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                onChanged: (value) => genero = value,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Selecciona un género'
                            : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ElevatedButton.icon(
            icon: Icon(Icons.check, color: Colors.white),
            label: Text(
              'Agregar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00A8E8),
              foregroundColor: Colors.white,
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
                final alumnoTemp = Alumno(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  nombres: nombres.trim(),
                  apellidos: apellidos.trim(),
                  edad: edad,
                  fechaNacimiento: fechaNacimiento!,
                  genero: genero!,
                  grupoId: widget.grupo.id,
                );

                final alumnos = await db.getAlumnosPorGrupo(widget.grupo.id);
                alumnos.add(alumnoTemp);
                alumnos.sort(
                  (a, b) => a.apellidos.toLowerCase().compareTo(
                    b.apellidos.toLowerCase(),
                  ),
                );

                for (int i = 0; i < alumnos.length; i++) {
                  alumnos[i].numeroLista = i + 1;
                  if (alumnos[i].id == alumnoTemp.id) {
                    await db.insertAlumno(alumnos[i]);
                  } else {
                    await db.updateAlumno(alumnos[i]);
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Alumno guardado correctamente')),
                );

                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget campoTexto({
    required String label,
    required IconData icono,
    required Function(String) onChanged,
  }) {
    return TextFormField(
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
        prefixIcon: Icon(icono, color: const Color(0xFF007EA7)),
        filled: true,
        fillColor: const Color(0xFFF3F8FC), // fondo suave
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00A8E8), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
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
    required Function(String) onChanged,
  }) {
    return TextFormField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
        ),
        prefixIcon: Icon(icono, color: const Color(0xFF007EA7)),
        filled: true,
        fillColor: const Color(0xFFF3F8FC), // fondo suave
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00A8E8), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      onChanged: onChanged,
      validator:
          (value) =>
              value == null || value.trim().isEmpty
                  ? 'Campo obligatorio'
                  : null,
    );
  }
}
