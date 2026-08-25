import 'package:flutter/foundation.dart';
import 'package:mysql1/mysql1.dart';

const local = !kReleaseMode;

const String scheme       = local ? 'http': 'https';
const String moucaServer  = local ? '192.168.73.166': 'mouca.fr';
const String adresse      = local ? '192.168.73.166': 'mouca.fr';
const String adresseHTTPS = local ? 'http://192.168.73.166' : 'https://mouca.fr';
const String adresseHTTP  = local ? 'http://192.168.73.166' : 'http://mouca.fr';
const int port            = local ? 3307            : 26321;

bool useDebug = local;

// WARNING: NEVER COMMIT
ConnectionSettings createConnection()
{
  return ConnectionSettings(
      host: adresse,
      port: port,
      user: 'StatitikCreator',
      password: 'eZ,RP-Cc^A}.Sz[,=8w-7r:G,_axcXmWk&pUpubfVe9awQPLt',
      db: useDebug ? 'StatitikPokemonDebug' : 'StatitikPokemon'
  );
}

ConnectionSettings createConnectionPoke()
{
  return ConnectionSettings(
      host: adresse,
      port: port,
      user: 'StatitikCreator',
      password: 'eZ,RP-Cc^A}.Sz[,=8w-7r:G,_axcXmWk&pUpubfVe9awQPLt',
      db: 'StatitikCardPoke'
  );
}