import 'package:flutter/material.dart';
import '../models/grupo.dart';
import '../db/database_helper.dart';
import 'lista_grupos_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CrearMateriaScreen extends StatefulWidget {
  @override
  _CrearMateriaScreenState createState() => _CrearMateriaScreenState();
}

class _CrearMateriaScreenState extends State<CrearMateriaScreen> {
  final _formKey = GlobalKey<FormState>();
  String nombreMateria = '';
  String nombreGrupo = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Nueva Clase')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre de la materia',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700], // opcional: mejor contraste
                  ),
                  prefixIcon: Icon(Icons.book, color: const Color(0xFF007EA7)),
                  filled: true,
                  fillColor: const Color(0xFFF3F8FC), // fondo suave
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00A8E8),
                      width: 2,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (value) => nombreMateria = value,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Campo obligatorio'
                            : null,
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre del grupo',
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700], // opcional: mejor contraste
                  ),
                  prefixIcon: Icon(Icons.group, color: const Color(0xFF007EA7)),
                  filled: true,
                  fillColor: const Color(0xFFF3F8FC), // fondo suave
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF00A8E8),
                      width: 2,
                    ),
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                onChanged: (value) => nombreGrupo = value,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Campo obligatorio'
                            : null,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: Icon(Icons.cancel),
                label: Text(
                  'Cancelar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.check),
                label: Text(
                  'Aceptar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(30, 124, 161, 1),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.black, width: 2),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final nuevoGrupo = Grupo(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nombre: '$nombreMateria - $nombreGrupo',
                      materia: nombreMateria,
                    );

                    await DatabaseHelper().insertarGrupo(nuevoGrupo);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Grupo creado correctamente')),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => ListaGruposScreen()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
