INSERT INTO `StatitikPokemon`.`Langue` (`idLangue`, `icone`) VALUES (1, 'france');
INSERT INTO `StatitikPokemon`.`Langue` (`idLangue`, `icone`) VALUES (2, 'usa');

INSERT INTO `StatitikPokemon`.`Extension` (`idExtension`, `idLangue`, `nom`, `code`) VALUES (1, 1, 'XY', 6);
INSERT INTO `StatitikPokemon`.`Extension` (`idExtension`, `idLangue`, `nom`, `code`) VALUES (2, 1, 'Soleil et Lune', 7);
INSERT INTO `StatitikPokemon`.`Extension` (`idExtension`, `idLangue`, `nom`, `code`) VALUES (3, 1, 'Epée et Bouclier', 8);

INSERT INTO `StatitikPokemon`.`SousExtension` (`idSousExtension`, `nom`, `icone`, `idExtension`, `cartes`, `code`) VALUES (1, 'Voltage Eclatant', 'swsh4', 3, 'PcPpPrPcPrPcPrPcPMPcPpPrPHPHPcPpPpPvPVPvRcRpRrRrRcRpRvErEcEHEcEpErEvEVEcErEpEcErWvWVWcWHWrWHWvWMWcWrWcWpWcWpWcWpWHWHWpYcYrYpYrYcYrYcYpYHYcYcYpYcYrYcYHYHYcYrYMCcCrCpCcCrCpCHCcCcCrCHCcCrCcCrCvCVCcCrCMOcOpOpOvOcOpOrOcOrMcMrMrMvMcMpMrMcMpMrMMMrMHMpMcMpMpMvMVMHMHIcIHIHIcIpIcIpIrIMIcIvIVIHIcIpIrdpdpdpdpspopopdpdHopopdpdpopopspepepepepPUPURUEUWUWUYUCUCUOUMUMUIUdUdUdUdUdUdUdUPAEAWACAMAIAdAdAdAdAdAdAOGIGoGoGoGoG', 4);

INSERT INTO `StatitikPokemon`.`Utilisateur` (`idUtilisateur`, `identifiant`, `ban`) VALUES (1, 'Administrator', 0);
