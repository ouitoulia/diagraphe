#!/usr/bin/env bash
################################################################################
#
#  Questo è uno script che aggiorna un ambiente di sviluppo con le ultime modifiche
#  È scontato che tu non lo debba usare in produzione.
#
#  Author: Pietro Arturo Panetta
#  Site: https://www.drupal.org/u/arturopanetta
#  Copyright: @arturu 2024
#  License: AGPL-3.0-only
#
################################################################################

composer update -W --no-cache
drush updb -y
drush cr
drush config:import -y --partial --source=$(drush drupal:directory)/modules/contrib/lexika/config/install
drush config:import -y --partial --source=$(drush drupal:directory)/modules/contrib/bibliotheke/config/install
drush config:import -y --partial --source=$(drush drupal:directory)/modules/contrib/prosopon/config/install
drush config:import -y --partial --source=$(drush drupal:directory)/modules/contrib/themethla/config/install
drush config:import -y --partial --source=$(drush drupal:directory)/modules/contrib/exesti/config/install
drush config:import -y --partial --source=$(drush drupal:directory)/modules/contrib/sunchronizo/config/install

drush migrate:import --update --all

drush config:import -y --partial --source=$(drush drupal:directory)/modules/contrib/prosis/config/install

drush updb -y

drush cr
