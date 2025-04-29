import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:excel/excel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize FFI for desktop platforms
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'esyria.db');
    print('Database path: $path');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

Future<void> _onCreate(Database db, int version) async {
  await db.execute('''
    CREATE TABLE records(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      surname TEXT,
      fatherName TEXT,
      motherName TEXT,
      birthPlace TEXT,
      birthDate TEXT,
      nationalId TEXT,
      registryOffice TEXT,
      registrationNumber TEXT,
      gender TEXT,
      faceColor TEXT,
      eyeColor TEXT,
      addresses TEXT,
      distinctiveMarks TEXT,
      contactInfo TEXT,
      currentResidence TEXT, 
      previousResidence TEXT, 
      maritalStatus TEXT,
      spouseName TEXT,
      childrenCount TEXT,
      wives TEXT,
      children TEXT,
      address TEXT,
      areaName TEXT,
      neighborhood TEXT,
      nearestLandmark TEXT,
      educationLevel TEXT,
      major TEXT,
      currentJob TEXT,
      previousJob TEXT,
      financialStatus TEXT,
      ethicalConduct TEXT,
      militaryService TEXT,
      joinedFactions TEXT,
      revolutionStance TEXT,
      relativesWithRegime TEXT,
      regimeRelation TEXT,
      regimeInfluence TEXT,
      relativesWithISIS TEXT,
      isisRelation TEXT,
      isisInfluence TEXT,
      imprisonedRelatives TEXT,
      imprisonmentReason TEXT,
      prisonLocation TEXT,
      prisonRelation TEXT,
      prisonInfluence TEXT,
      religiousCommitment TEXT,
      intellectualOrientation TEXT,
      societyInfluence TEXT,
      personalTraits TEXT,
      lifeSummary TEXT,
      securityReport TEXT,
      pastActivities TEXT,
      criminalRecord TEXT,
      influentialRelations TEXT,
      trustLevel TEXT,
      pastMovements TEXT,
      weaponPossession TEXT,
      booksRead TEXT,
      religiousActivities TEXT,
      assets TEXT,
      suspiciousTransactions TEXT,
      socialNetworks TEXT,
      createdAt TEXT,
      mainImage TEXT,
      idFront TEXT,
      idBack TEXT,
      extraDocs TEXT,
      works TEXT
    )
  ''');
}


  Future<int> insertRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('records', record);
  }

  Future<List<Map<String, dynamic>>> searchRecords(String query) async {
    final db = await database;
    final results = await db.query(
      'records',
      where: 'name LIKE ? OR surname LIKE ? OR nationalId LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return results;
  }

  Future<void> exportDatabase() async {
    final db = await database;
    final dbPath = await getDatabasesPath();
    final dbFile = File('$dbPath/esyria.db');
    
    if (!dbFile.existsSync()) {
      throw Exception('Database file not found');
    }

    final exportDir = await getApplicationDocumentsDirectory();
    final exportPath = '${exportDir.path}/esyria_export_${DateTime.now().millisecondsSinceEpoch}.sql';
    final exportFile = File(exportPath);

    // Export the database schema
    final schema = await rootBundle.loadString('assets/schema.sql');
    await exportFile.writeAsString(schema);

    // Export the data
    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    for (final table in tables) {
      final tableName = table['name'];
      if (tableName == 'sqlite_sequence') continue;
      
      final rows = await db.query(tableName as String);
      for (final row in rows) {
        final columns = row.keys.join(', ');
        final values = row.values.map((v) => "'$v'").join(', ');
        await exportFile.writeAsString(
          "INSERT INTO $tableName ($columns) VALUES ($values);\n",
          mode: FileMode.append,
        );
      }
    }
  }

  Future<int> _estimateRecordSize(Map<String, dynamic> record) async {
    // Estimate size of JSON data
    int size = utf8.encode(jsonEncode(record)).length;

    // Estimate size of images
    if (record['mainImage'] != null) {
      size += await File(record['mainImage']).length();
    }
    if (record['idFront'] != null) {
      size += await File(record['idFront']).length();
    }
    if (record['idBack'] != null) {
      size += await File(record['idBack']).length();
    }
    if (record['extraDocs'] != null) {
      final extraDocs = List<String>.from(jsonDecode(record['extraDocs']));
      for (final doc in extraDocs) {
        size += await File(doc).length();
      }
    }

    return size;
  }

  Future<int> _getAvailableDiskSpace() async {
    final directory = await getApplicationDocumentsDirectory();
    final stat = await directory.stat();
    return stat.size;
  }

  Future<int> updateRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.update(
      'records',
      record,
      where: 'id = ?',
      whereArgs: [record['id']],
    );
  }

  Future<void> exportToExcel() async {
    final db = await database;
    final excel = Excel.createExcel();
    
    final sheet = excel['records'];
    final headers = [
      'id', 'name', 'surname', 'fatherName', 'motherName', 'birthPlace', 
      'birthDate', 'nationalId', 'registryOffice', 'registrationNumber',
      'gender', 'faceColor', 'eyeColor', 'addresses', 'distinctiveMarks',
      'contactInfo', 'currentResidence', 'previousResidence', 'maritalStatus',
      'spouseName', 'childrenCount', 'wives', 'children', 'address', 'areaName',
      'neighborhood', 'nearestLandmark', 'educationLevel', 'major', 'currentJob',
      'previousJob', 'financialStatus', 'ethicalConduct', 'militaryService',
      'joinedFactions', 'revolutionStance', 'relativesWithRegime', 'regimeRelation',
      'regimeInfluence', 'relativesWithISIS', 'isisRelation', 'isisInfluence',
      'imprisonedRelatives', 'imprisonmentReason', 'prisonLocation', 'prisonRelation',
      'prisonInfluence', 'religiousCommitment', 'intellectualOrientation',
      'societyInfluence', 'personalTraits', 'lifeSummary', 'securityReport',
      'pastActivities', 'criminalRecord', 'influentialRelations', 'trustLevel',
      'pastMovements', 'weaponPossession', 'booksRead', 'religiousActivities',
      'assets', 'suspiciousTransactions', 'socialNetworks', 'createdAt',
      'mainImage', 'idFront', 'idBack', 'extraDocs', 'works'
    ];

    for (var i = 0; i < headers.length; i++) {
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0)).value = TextCellValue(headers[i]);
    }

    final records = await db.query('records');

    for (var i = 0; i < records.length; i++) {
      final record = records[i];
      for (var j = 0; j < headers.length; j++) {
        final value = record[headers[j].toLowerCase().replaceAll(' ', '')]?.toString() ?? '';
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 1)).value = TextCellValue(value);
      }
    }

    final exportDir = await getApplicationDocumentsDirectory();
    final exportPath = '${exportDir.path}/esyria_export_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final file = File(exportPath);
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to encode Excel file');
    }
    await file.writeAsBytes(bytes);
  }

  Future<void> importFromExcel(File excelFile) async {
    final db = await database;
    final bytes = await excelFile.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    
    final sheet = excel['records'];
    if (sheet == null) {
      throw Exception('Sheet "records" not found in Excel file');
    }

    final headers = <String>[];
    for (var cell in sheet.row(0)) {
      if (cell?.value != null) {
        headers.add(cell!.value.toString());
      }
    }

    for (var row in sheet.rows.skip(1)) {
      final record = <String, dynamic>{};
      for (var i = 0; i < headers.length; i++) {
        final header = headers[i].toLowerCase().replaceAll(' ', '');
        final value = row[i]?.value?.toString();
        if (value != null && value.isNotEmpty) {
          record[header] = value;
        }
      }

      final existing = await db.query(
        'records',
        where: 'id = ?',
        whereArgs: [record['id']],
      );

      if (existing.isNotEmpty) {
        await db.update('records', record, where: 'id = ?', whereArgs: [record['id']]);
      } else {
        await db.insert('records', record);
      }
    }
  }
}
