import 'package:postgres/postgres.dart';

class Database {

  factory Database() => _instance;

  Database._internal() {
    connection = PostgreSQLConnection(
      'localhost',
      5432,
      'pilot_repair',
      username: 'postgres',
      password: '******',
    );
  }
  static final Database _instance = Database._internal();

  /// Getter agar bisa akses `Database.instance`
  static Database get instance => _instance;

  late PostgreSQLConnection connection;

  Future<void> connect() async {
    if (connection.isClosed) {
      connection = PostgreSQLConnection(
        'localhost',
        5432,
        'pilot_repair',
        username: 'postgres',
        password: '******',
      );
      await connection.open();
    }
  }
}
