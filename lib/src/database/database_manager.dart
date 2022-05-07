import 'dart:convert';

import 'package:encrypt/encrypt.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sublime/src/models/metadata.dart';
import 'package:sublime/src/models/sequence.dart';
import 'package:sublime/src/models/subtitle.dart';
import 'package:sublime/src/utilities/constants.dart';

// Logger
final Logger log = Logger();

class DatabaseManager {
  static const _databaseName = 'sublime.db';
  static const _databaseVersion = 1;
  static const _encryptionKey = 'SUBLIME_PRIVATE_KEY_2022';

  static final DatabaseManager _instance = DatabaseManager._();
  static Database? _database;

  DatabaseManager._();

  factory DatabaseManager() {
    return _instance;
  }

  /// Gives the database path for this app
  Future<String> _getDatabasePath() async {
    return join(await getDatabasesPath(), _databaseName);
  }

  /// Opens the database for this app, if the database already exists and it is
  /// not open. If the database does not already exist, a new one is created.
  Future<void> open() async {
    if (_database?.isOpen == true) {
      return;
    }

    try {
      final String databasePath = await _getDatabasePath();

      _database = await openDatabase(databasePath, version: _databaseVersion,
          onCreate: (Database database, int version) async {
        await database.transaction((txn) async {
          // Creating subtitle table
          await txn.execute('CREATE TABLE ${Subtitle.tabSubtitle}('
              '${Subtitle.colSubtitleId} INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
              '${Subtitle.colSubtitleName} TEXT NOT NULL, '
              '${Subtitle.colDateTimeCreated} TEXT NOT NULL, '
              '${Subtitle.colDateTimeModified} TEXT NOT NULL, '
              '${Subtitle.colCurrentSequenceId} INTEGER NOT NULL, '
              '${Subtitle.colIsFavorite} INTEGER NOT NULL '
              'CHECK(${Subtitle.colIsFavorite} IN (0, 1)), '
              '${Subtitle.colVideoPath} TEXT NOT NULL)');

          // Creating sequence table
          await txn.execute('CREATE TABLE ${Sequence.tabSequence}('
              '${Sequence.colSubtitleId} INTEGER NOT NULL '
              'REFERENCES ${Subtitle.tabSubtitle}(${Subtitle.colSubtitleId}), '
              '${Sequence.colSequenceId} INTEGER NOT NULL, '
              '${Sequence.colSequenceNo} INTEGER NOT NULL, '
              '${Sequence.colStartTime} TEXT NOT NULL, '
              '${Sequence.colEndTime} TEXT NOT NULL, '
              '${Sequence.colOriginalText} TEXT NOT NULL, '
              '${Sequence.colTranslatedText} TEXT NOT NULL, '
              '${Sequence.colIsCompleted} INTEGER NOT NULL '
              'CHECK(${Sequence.colIsCompleted} IN (0, 1)), '
              'UNIQUE(${Sequence.colSubtitleId}, ${Sequence.colSequenceId}))');
        });
      });
    } catch (exception) {
      Fluttertoast.showToast(
        msg: databaseOpeningFailed,
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  /// Closes the database for this app, if the database exists and it is open.
  Future<void> close() async {
    if (_database?.isOpen == true) {
      _database!.close();
    }
  }

  Future<int> insertSubtitle(Subtitle subtitle) async {
    // Opening database
    await open();

    // Inserting subtitle to the database
    await _database!.transaction((txn) async {
      // Preparing arguments
      final List subtitleArgs = [
        subtitle.subtitleName,
        subtitle.dateTimeCreated.toIso8601String(),
        subtitle.dateTimeModified.toIso8601String(),
        subtitle.currentSequenceId,
        subtitle.isFavorite ? 1 : 0,
        subtitle.videoPath,
      ];

      // Performing query to insert subtitle
      subtitle.subtitleId = await txn.rawInsert(
          'INSERT INTO ${Subtitle.tabSubtitle}('
          '${Subtitle.colSubtitleName}, '
          '${Subtitle.colDateTimeCreated}, '
          '${Subtitle.colDateTimeModified}, '
          '${Subtitle.colCurrentSequenceId}, '
          '${Subtitle.colIsFavorite}, '
          '${Subtitle.colVideoPath}) '
          'VALUES(?, ?, ?, ?, ?, ?)',
          subtitleArgs);

      // Performing query to inserting sequences
      final Batch batch = txn.batch();

      subtitle.sequenceList!.asMap().forEach((index, element) async {
        element.subtitleId = subtitle.subtitleId;
        element.sequenceId = index + 1;

        // Preparing arguments
        final List sequenceArgs = [
          element.subtitleId,
          element.sequenceId,
          element.sequenceNo,
          element.startTime,
          element.endTime,
          element.originalText,
          element.translatedText,
          element.isCompleted ? 1 : 0,
        ];

        batch.rawInsert(
            'INSERT INTO ${Sequence.tabSequence}('
            '${Sequence.colSubtitleId}, '
            '${Sequence.colSequenceId}, '
            '${Sequence.colSequenceNo}, '
            '${Sequence.colStartTime}, '
            '${Sequence.colEndTime}, '
            '${Sequence.colOriginalText}, '
            '${Sequence.colTranslatedText}, '
            '${Sequence.colIsCompleted}) '
            'VALUES(?, ?, ?, ?, ?, ?, ?, ?)',
            sequenceArgs);
      });

      await batch.commit(noResult: true);
    });

    return subtitle.subtitleId!;
  }

  Future<void> deleteSubtitle(int subtitleId) async {
    // Opening database
    await open();

    // Deleting subtitle from the database
    await _database!.transaction((txn) async {
      // Performing query to delete subtitle
      await txn.rawDelete(
          'DELETE FROM ${Subtitle.tabSubtitle} WHERE '
          '${Subtitle.colSubtitleId} = ?',
          [subtitleId]);

      // Performing query to deleting sequences
      await txn.rawDelete(
          'DELETE FROM ${Sequence.tabSequence} WHERE ${Sequence.colSubtitleId} = ?',
          [subtitleId]);
    });
  }

  Future<void> updateSequence(Sequence sequence) async {
    // Opening database
    await open();

    // Preparing arguments
    final List sequenceArgs = [
      sequence.translatedText,
      sequence.isCompleted ? 1 : 0,
      sequence.subtitleId,
      sequence.sequenceId,
    ];

    // Performing query to update sequence
    await _database!.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ${Sequence.tabSequence} '
          'SET ${Sequence.colTranslatedText} = ?, ${Sequence.colIsCompleted} = ? '
          'WHERE ${Sequence.colSubtitleId} = ? AND ${Sequence.colSequenceId} = ?',
          sequenceArgs);
    });
  }

  Future<void> updateSubtitleName(Subtitle subtitle) async {
    // Opening database
    await open();

    // Preparing arguments
    final List subtitleArgs = [
      subtitle.subtitleName,
      subtitle.subtitleId,
    ];

    // Performing query to update subtitle name
    await _database!.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ${Subtitle.tabSubtitle} '
          'SET ${Subtitle.colSubtitleName} = ? WHERE ${Subtitle.colSubtitleId} = ?',
          subtitleArgs);
    });
  }

  Future<void> updateSubtitleIsFavorite(Subtitle subtitle) async {
    // Opening database
    await open();

    // Preparing arguments
    final List subtitleArgs = [
      subtitle.isFavorite ? 1 : 0,
      subtitle.subtitleId,
    ];

    // Performing query to update subtitle name
    await _database!.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ${Subtitle.tabSubtitle} '
          'SET ${Subtitle.colIsFavorite} = ? WHERE ${Subtitle.colSubtitleId} = ?',
          subtitleArgs);
    });
  }

  Future<void> updateSubtitleVideoPath(Subtitle subtitle) async {
    // Opening database
    await open();

    // Preparing arguments
    final List subtitleArgs = [
      subtitle.videoPath,
      subtitle.subtitleId,
    ];

    // Performing query to update subtitle video path
    await _database!.transaction((txn) async {
      await txn.rawUpdate(
          'UPDATE ${Subtitle.tabSubtitle} '
          'SET ${Subtitle.colVideoPath} = ? WHERE ${Subtitle.colSubtitleId} = ?',
          subtitleArgs);
    });
  }

  Future<Subtitle?> selectSubtitle(int subtitleId) async {
    // Opening database
    await open();

    Subtitle? subtitle;

    try {
      // Performing query to retrieve subtitles
      await _database!.transaction((txn) async {
        final List<Map<String, dynamic>> queryResult = await txn.rawQuery(
            'SELECT * FROM ${Subtitle.tabSubtitle} INNER JOIN '
            '(SELECT ${Sequence.colSubtitleId}, COUNT(*) AS ${Metadata.colNoOfSequences}, '
            'SUM(${Sequence.colIsCompleted} = 1) AS ${Metadata.colNoOfCompletedSequences}, '
            'SUM(${Sequence.colIsCompleted} = 0 AND LENGTH(${Sequence.colTranslatedText}) > 0) '
            'AS ${Metadata.colNoOfDraftSequences} FROM ${Sequence.tabSequence} '
            'GROUP BY ${Sequence.colSubtitleId}) USING(${Sequence.colSubtitleId}) '
            'WHERE ${Subtitle.colSubtitleId} = ?',
            [subtitleId]);

        final List<Subtitle> subtitleList =
            queryResult.map((element) => Subtitle.fromMap(element)).toList();

        if (subtitleList.isNotEmpty) {
          subtitle = subtitleList.first;
        }
      });
    } catch (exception) {
      // Catch exception
    }

    return subtitle;
  }

  Future<List<Subtitle>?> selectSubtitles(Map<String, bool> orderBy) async {
    // Opening database
    await open();

    List<Subtitle>? subtitleList;

    List<String> orderByList = [];

    orderBy.forEach((columnName, isAscending) {
      orderByList.add(columnName + (isAscending ? ' ASC' : ' DESC'));
    });

    String orderByString = orderByList.join(', ');

    try {
      // Performing query to retrieve subtitles
      await _database!.transaction((txn) async {
        final List<Map<String, dynamic>> queryResult = await txn.rawQuery(
            'SELECT * FROM ${Subtitle.tabSubtitle} INNER JOIN '
            '(SELECT ${Sequence.colSubtitleId}, COUNT(*) AS ${Metadata.colNoOfSequences}, '
            'SUM(${Sequence.colIsCompleted} = 1) AS ${Metadata.colNoOfCompletedSequences}, '
            'SUM(${Sequence.colIsCompleted} = 0 AND LENGTH(${Sequence.colTranslatedText}) > 0) '
            'AS ${Metadata.colNoOfDraftSequences} FROM ${Sequence.tabSequence} '
            'GROUP BY ${Sequence.colSubtitleId}) USING(${Sequence.colSubtitleId}) '
            'ORDER BY $orderByString');

        subtitleList =
            queryResult.map((element) => Subtitle.fromMap(element)).toList();
      });
    } catch (exception) {
      // Catch exception
    }

    return subtitleList;
  }

  Future<List<Sequence>?> selectSequences(int subtitleId) async {
    // Opening database
    await open();

    List<Sequence>? sequenceList;

    try {
      // Performing query to retrieve sequences
      await _database!.transaction((txn) async {
        final List<Map<String, dynamic>> queryResult = await txn.rawQuery(
            'SELECT * FROM ${Sequence.tabSequence} WHERE ${Sequence.colSubtitleId} = ?',
            [subtitleId]);

        sequenceList =
            queryResult.map((element) => Sequence.fromMap(element)).toList();
      });
    } catch (exception) {
      // Catch exception
    }

    return sequenceList;
  }

  Future<String> createBackup() async {
    // Opening database
    await open();

    const int version = _databaseVersion;
    final List<String> tables = [Subtitle.tabSubtitle, Sequence.tabSequence];
    final List<List<Map<String, dynamic>>> data = [];

    // Retrieving data from the database
    for (String table in tables) {
      data.add(await _database!.query(table));
    }

    final Map<String, dynamic> backup = {
      'version': version,
      'tables': tables,
      'data': data,
    };

    final String json = jsonEncode(backup);

    // Encrypting data
    final Key key = Key.fromUtf8(_encryptionKey);
    final IV iv = IV.fromLength(16);
    final Encrypter encrypter = Encrypter(AES(key));
    final Encrypted encrypted = encrypter.encrypt(json, iv: iv);

    String encryptedBytes = encrypted.base64;

    return encryptedBytes;
  }

  Future<void> restoreBackup(String encryptedBytes) async {
    // Closing and deleting existing database
    await close();
    await deleteDatabase(await _getDatabasePath());

    // Creating new database
    await open();

    // Decrypting data
    final Key key = Key.fromUtf8(_encryptionKey);
    final IV iv = IV.fromLength(16);
    final Encrypter encrypter = Encrypter(AES(key));
    final String json = encrypter.decrypt64(encryptedBytes, iv: iv);

    final Map<String, dynamic> backup = jsonDecode(json);

    final int version = backup['version'];
    final List<dynamic> tables = backup['tables'];
    final List<dynamic> data = backup['data'];

    // Database schema version check
    if (version != _databaseVersion) {
      throw Exception('Database version does not match.');
    }

    // Inserting all data into respective tables
    final Batch batch = _database!.batch();

    tables.asMap().forEach((index, table) {
      data[index].forEach((row) {
        batch.insert(table, row);
      });
    });

    await batch.commit(noResult: true);
  }
}
