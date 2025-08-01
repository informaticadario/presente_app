class Alumno {
  final String id;
  final String nombres; // Ejemplo: José Luis
  final String apellidos; // Ejemplo: Navarro Contreras
  final int edad;
  final DateTime fechaNacimiento; // 🔄 ahora es DateTime
  final String genero;
  final String grupoId;
  String estadoAsistencia;
  int numeroLista;

  Alumno({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.edad,
    required this.fechaNacimiento, // 👈 tipo actualizado
    required this.genero,
    required this.grupoId,
    this.estadoAsistencia = 'Sin marcar',
    this.numeroLista = -1,
  });

  factory Alumno.fromMap(Map<String, dynamic> map) {
    return Alumno(
      id: map['id'],
      nombres: map['nombres'],
      apellidos: map['apellidos'],
      edad: map['edad'],
      fechaNacimiento: DateTime.parse(map['fechaNacimiento']), // 👈 decodificar
      genero: map['genero'],
      grupoId: map['grupoId'],
      estadoAsistencia: map['estadoAsistencia'] ?? 'Sin marcar',
      numeroLista: map['numeroLista'] ?? -1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
      'edad': edad,
      'fechaNacimiento':
          fechaNacimiento.toIso8601String(), // 👈 guardar como String
      'genero': genero,
      'grupoId': grupoId,
      'estadoAsistencia': estadoAsistencia,
      'numeroLista': numeroLista,
    };
  }

  String get nombreCompleto => '${apellidos.trim()}, ${nombres.trim()}';
}
