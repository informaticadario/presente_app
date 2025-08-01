// listagrupos_screen.dart

import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/grupo.dart';
import 'detalle_grupo_screen.dart';
import 'crear_materia_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class ListaGruposScreen extends StatefulWidget {
  @override
  _ListaGruposScreenState createState() => _ListaGruposScreenState();
}

class _ListaGruposScreenState extends State<ListaGruposScreen> {
  List<Grupo> grupos = [];

  @override
  void initState() {
    super.initState();
    cargarGrupos();
  }

  Future<void> cargarGrupos() async {
    final db = DatabaseHelper();
    final lista = await db.getGrupos();
    setState(() {
      grupos = lista;
    });
  }

  Future<void> eliminarGrupo(Grupo grupo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('¿Eliminar grupo?'),
            content: Text('Se eliminará el grupo y todos sus alumnos.'),
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
      final db = DatabaseHelper();
      await db.deleteGrupo(grupo.id);
      await cargarGrupos();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Grupo eliminado correctamente 🗑️')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mis Grupos')),
      body:
          grupos.isEmpty
              ? Center(child: Text('No hay grupos registrados'))
              : ListView.builder(
                itemCount: grupos.length,
                itemBuilder: (context, index) {
                  final grupo = grupos[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.folder,
                        color: Color(0xFF007EA7),
                        size: 32,
                      ),
                      title: Text(
                        grupo.nombre,
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        'Materia: ${grupo.materia}',
                        style: GoogleFonts.raleway(fontSize: 14),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Eliminar grupo',
                            onPressed: () => eliminarGrupo(grupo),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 20),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetalleGrupoScreen(grupo: grupo),
                          ),
                        ).then((_) => cargarGrupos());
                      },
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 232, 73, 0),
        tooltip: 'Crear nuevo grupo',
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CrearMateriaScreen()),
          );
          await cargarGrupos();
        },
      ),
    );
  }
}
