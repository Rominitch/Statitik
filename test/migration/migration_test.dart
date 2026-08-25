import 'package:flutter_test/flutter_test.dart';
import 'package:statitikcard/models/poke_collection.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/services/environment.dart';
import 'package:statitikcard/services/tools.dart';

void main() {
  test('MigrationPokeExpansions', () async {
    PokeCollection collection = PokeCollection();

    final dbPoke = Database.poke();

    // Read DB
    try {
      await dbPoke.transactionR((connection) async {
        await collection.readStaticData(connection);
      });
    } catch (onError) {
      fail("Impossible to read database: $onError");
    }
    // Write new DB
    try {
      await dbPoke.transactionR((connection) async {
        // Migrate
        for (final exp in collection.expansions()) {
          await collection.updatePokeExpansion(exp, connection);
        }
        // Try to read before release transaction
        collection = PokeCollection();
        await collection.readStaticData(connection);
      });
    } catch (onError) {
      fail("Impossible to write database: $onError");
    }
  });
  test('MigrationCleanUselessCards', () async {
    PokeCollection collection = PokeCollection();

    final dbPoke = Database.poke();

    // Read DB
    try {
      await dbPoke.transactionR((connection) async {
        await collection.readStaticData(connection);
      });

      Set<PokeIdentifier> linked = {};
      for(final expansion in collection.expansions()) {
        for(final cardGroup in expansion.cards.cards) {
          for(final card in cardGroup) {
            linked.add(card.card.pid());
          }
        }
        for(final card in expansion.cards.energyCard) {
          linked.add(card.card.pid());
        }
        for(final card in expansion.cards.noNumberedCard) {
          linked.add(card.card.pid());
        }
      }

      printOutput("Nombre de cartes:\t\t${collection.cards().length}");
      printOutput("Nombre de cartes liées:\t${linked.length}");

      await dbPoke.transactionR((connection) async {
        final List<List<Object?>> queries = [];
        for( final card in collection.cards() ) {
          if( !linked.contains(card.pid()) ) {
            queries.add([card.pid().id()]);
          }
        }
        printOutput("Cartes à supprimer:\t${queries.length}");
        await connection.queryMulti("DELETE FROM `StatitikCardPoke`.`PK_cartes` WHERE id = ?;",
            queries);
      });
    } catch (onError) {
      fail("Impossible to read database: $onError");
    }
  });

  test('MigrationProducts', () async {
    PokeCollection collection = PokeCollection();

    final dbPoke = Database.poke();

    // Read DB
    try {
      await dbPoke.transactionR((connection) async {
        await collection.readStaticData(connection);
      });
    } catch (onError) {
      fail("Impossible to read database: $onError");
    }
    // Write new DB
    try {
      await dbPoke.transactionR((connection) async {
        // Migrate
        await collection.updateProducts(connection);

        // Try to read before release transaction
        collection = PokeCollection();
        await collection.readStaticData(connection);
      });
    } catch (onError) {
      fail("Impossible to write database: $onError");
    }
  });
  /*
  test('MigrationPokeCards', () async {
    PokeCollection collection = PokeCollection();

    final db_poke = Database.poke();

    // Read DB
    try {
      await db_poke.transactionR((connection) async {
        await collection.readStaticData(connection);
      });
    } catch (onError) {
      fail("Impossible to read database: $onError");
    }
    // Write new DB
    try {
      await db_poke.transactionR((connection) async {
        // Migrate
        final List<List<Object?>> queries = [];
        for (final card in collection.cardsOld()) {
          final writer = BinaryWriter();
          card.toBytes(writer);
          queries.add(
          [
            card.pid().id(),
            writer.toBytes()
          ]);
        }
        await collection.updatePokeCard(queries, connection);
        // Try to read before release transaction
        collection = PokeCollection();
        await collection.readStaticData(connection);
      });
    } catch (onError) {
      fail("Impossible to write database: $onError");
    }
  });
  */
}