import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';

const local = !kReleaseMode;
const ventoux = true;
const String adresse     = local ? (ventoux ? '192.168.1.65' : '192.168.73.166'): 'mouca.fr';
const String adresseHTML = 'https://mouca.fr';
const int port           = local ? (ventoux ? 3306 : 3307) : 26321;

bool useDebug = local;

// WARNING: NEVER COMMIT
ConnectionSettings createConnection()
{
  return new ConnectionSettings(
      host: adresse,
      port: port,
      user: 'StatitikCreator',
      password: ',}C33]C14Sn0LT:u:S!x',
      db: useDebug ? (ventoux ? 'statitikpokemon' :'StatitikPokemonDebug') : 'StatitikPokemon'
  );
}