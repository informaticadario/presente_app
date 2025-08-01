import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/grupo.dart';
import '../models/alumno.dart';

class DatabaseHelper {
  static final DatabaseHelper _instancia = DatabaseHelper._interno();
  static Database? _database;

  DatabaseHelper._interno();

  factory DatabaseHelper() => _instancia;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await iniciarBD();
    return _database!;
  }

  Future<Database> iniciarBD() async {
    final path = join(await getDatabasesPath(), 'asistencia.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE grupos (
            id TEXT PRIMARY KEY,
            nombre TEXT,
            materia TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE alumnos (
            id TEXT PRIMARY KEY,
            nombres TEXT,
            apellidos TEXT,
            numeroLista INTEGER,
            edad INTEGER,
            fechaNacimiento TEXT,
            genero TEXT,
            estadoAsistencia TEXT,
            grupoId TEXT,
            FOREIGN KEY (grupoId) REFERENCES grupos(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE asistencias_por_dia (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            alumnoId TEXT,
            grupoId TEXT,
            fecha TEXT,
            estado TEXT,
            FOREIGN KEY (alumnoId) REFERENCES alumnos(id),
            FOREIGN KEY (grupoId) REFERENCES grupos(id)
          )
        ''');
      },
    );
  }

  // ------------------- GRUPOS -------------------

  Future<void> insertarGrupo(Grupo grupo) async {
    final db = await database;
    await db.insert(
      'grupos',
      grupo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Grupo>> getGrupos() async {
    final db = await database;
    final resultado = await db.query('grupos');
    return resultado.map((g) => Grupo.fromMap(g)).toList();
  }

  Future<void> deleteGrupo(String grupoId) async {
    final db = await database;

    // Eliminar asistencias relacionadas con el grupo
    await db.delete(
      'asistencias_por_dia',
      where: 'grupoId = ?',
      whereArgs: [grupoId],
    );

    // Eliminar alumnos del grupo
    await db.delete('alumnos', where: 'grupoId = ?', whereArgs: [grupoId]);

    // Eliminar el grupo
    await db.delete('grupos', where: 'id = ?', whereArgs: [grupoId]);
  }

  // ------------------- Actualizar Lista -------------------
  Future<void> updateNumeroLista(String id, int nuevoNumero) async {
    final db = await database;
    await db.update(
      'alumnos',
      {'numeroLista': nuevoNumero},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ------------------- ALUMNOS -------------------

  Future<void> insertAlumno(Alumno alumno) async {
    final db = await database;
    await db.insert(
      'alumnos',
      alumno.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateAlumno(Alumno alumno) async {
    final db = await database;
    await db.update(
      'alumnos',
      alumno.toMap(),
      where: 'id = ?',
      whereArgs: [alumno.id],
    );
  }

  Future<void> eliminarAlumno(String id) async {
    final db = await database;
    await db.delete('alumnos', where: 'id = ?', whereArgs: [id]);
    await db.delete(
      'asistencias_por_dia',
      where: 'alumnoId = ?',
      whereArgs: [id],
    );
  }

  Future<List<Alumno>> getAlumnosPorGrupo(String grupoId) async {
    final db = await database;
    final resultado = await db.query(
      'alumnos',
      where: 'grupoId = ?',
      whereArgs: [grupoId],
      orderBy: 'numeroLista ASC',
    );
    return resultado.map((a) => Alumno.fromMap(a)).toList();
  }

  // ------------------- ASISTENCIA POR DÍA -------------------

  Future<void> registrarAsistenciaPorDia({
    required String alumnoId,
    required String grupoId,
    required String estado,
    required String fecha,
  }) async {
    final db = await database;

    final existe = await db.query(
      'asistencias_por_dia',
      where: 'alumnoId = ? AND grupoId = ? AND fecha = ?',
      whereArgs: [alumnoId, grupoId, fecha],
    );

    if (existe.isNotEmpty) {
      await db.update(
        'asistencias_por_dia',
        {'estado': estado},
        where: 'alumnoId = ? AND grupoId = ? AND fecha = ?',
        whereArgs: [alumnoId, grupoId, fecha],
      );
    } else {
      await db.insert('asistencias_por_dia', {
        'alumnoId': alumnoId,
        'grupoId': grupoId,
        'fecha': fecha,
        'estado': estado,
      });
    }
  }

  Future<void> deleteAlumnosPorGrupo(String grupoId) async {
    final db = await database;
    await db.delete('alumnos', where: 'grupoId = ?', whereArgs: [grupoId]);
  }

  Future<bool> existeAsistenciaDelGrupo(String grupoId, String fecha) async {
    final db = await database;
    final resultado = await db.query(
      'asistencias_por_dia',
      where: 'grupoId = ? AND fecha = ?',
      whereArgs: [grupoId, fecha],
    );
    return resultado.isNotEmpty;
  }
}
