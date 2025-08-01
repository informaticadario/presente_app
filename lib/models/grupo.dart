class Grupo {
  final String id;
  final String nombre;
  final String materia;

  Grupo({required this.id, required this.nombre, required this.materia});

  factory Grupo.fromMap(Map<String, dynamic> map) {
    return Grupo(id: map['id'], nombre: map['nombre'], materia: map['materia']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'materia': materia};
  }
}
