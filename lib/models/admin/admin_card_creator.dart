import 'package:statitikcard/models/card/poke_card.dart';
import 'package:statitikcard/models/card/poke_card_design.dart';
import 'package:statitikcard/models/card/poke_card_in_expansion.dart';
import 'package:statitikcard/models/card/poke_card_type.dart';
import 'package:statitikcard/models/poke_data_navigation.dart';
import 'package:statitikcard/models/poke_design.dart';
import 'package:statitikcard/models/poke_expansion.dart';
import 'package:statitikcard/models/poke_identifier.dart';
import 'package:statitikcard/models/poke_language.dart';
import 'package:statitikcard/models/poke_rarity.dart';
import 'package:statitikcard/models/poke_set.dart';

class AdminCardCreator {
  final PokeNavAdmin _nav;
  PokeExpansion expansion;

  PokeCardType type = PokeCardType.plante;
  PokeRarity   rarity;

  AdminCardCreator(this._nav, this.expansion) :
    rarity = _nav.collection.unknownRarity();

  PokeNavAdmin nav() { return _nav; }

  PokeCardInExpansion newCard() {
    // Create new card
    final card    = PokeCard.newCard(type);
    final setInfo = computeBestSetInfo(rarity);
    return PokeCardInExpansion(card, rarity, "", isSecret(rarity), setInfo);
  }

  Map<PokeSet, List<PokeCardDesign>> computeBestSetInfo(PokeRarity r) {
    Map<PokeSet, List<PokeCardDesign>> setInfo = {};
    for(final set in _nav.collection.allSets())
    {
      setInfo[set] = [];
    }
    if (expansion.location() == CardLocation.Monde) {
      final normal   = _nav.collection.sets(PokeIdentifier(530000000))!;
      final holo     = _nav.collection.sets(PokeIdentifier(530000001))!;
      final parallel = _nav.collection.sets(PokeIdentifier(530000002))!;

      final designNormal = _nav.collection.design(PokeIdentifier(510000000))!;

      if (rarity.id() == 0 || rarity.id() == 2) {
        setInfo[normal]!.add(PokeCardDesign(designNormal, ArtFormat.normal));
        setInfo[parallel]!.add(PokeCardDesign(designNormal, ArtFormat.normal));
      } else if (rarity.id() == 4) {
        setInfo[holo]!.add(PokeCardDesign(designNormal, ArtFormat.normal));
      } else if (rarity.id() == 13) {
        setInfo[normal]!.add(PokeCardDesign(designNormal, ArtFormat.halfArt));
      } else if (rarity.id() == 37) {
        final designArcEnCiel = _nav.collection.design(PokeIdentifier(510000003))!;
        setInfo[normal]!.add(PokeCardDesign(designArcEnCiel, ArtFormat.fullArt));
      } else if (rarity.id() == 36) {
        final designGold = _nav.collection.design(PokeIdentifier(510000004))!;
        setInfo[normal]!.add(PokeCardDesign(designGold, ArtFormat.fullArt));
      } else if (rarity.id() == 13) {
        final designFull = _nav.collection.design(PokeIdentifier(510000007))!;
        setInfo[normal]!.add(PokeCardDesign(designFull, ArtFormat.halfArt));
      } else if (rarity.id() == 18) {
        final designFull = _nav.collection.design(PokeIdentifier(510000007))!;
        setInfo[normal]!.add(PokeCardDesign(designFull, ArtFormat.fullArt));
      } else if (rarity.id() == 6) {
        final designHolo = _nav.collection.design(PokeIdentifier(510000001))!;
        setInfo[normal]!.add(PokeCardDesign(designHolo, ArtFormat.normal));
      }
    }
    return setInfo;
  }

  bool isSecret(PokeRarity r) {
    // From DB
    final List<int> secretRarities = const [21, 22, 23, 24, 25, 26, 27, 36, 37];
    return secretRarities.contains(r.id());
  }
}