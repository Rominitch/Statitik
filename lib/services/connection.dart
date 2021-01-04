import 'package:mysql1/mysql1.dart';

ConnectionSettings createConnection()
{
  return new ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'MyUser',
        password: 'MyPassword',
        db: 'MyDatabase'
    );
}