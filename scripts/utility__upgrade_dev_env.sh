#!/usr/bin/env bash
################################################################################
#
#  Questo è uno script che aggiorna un ambiente di sviluppo con le ultime modifiche
#  È scontato che tu non lo debba usare in produzione.
#  Ed è anche scontato che possa rompere la tua installazione.
#
#  Uso: posizionati nella root di drupal (dove c'è composer.json)
#  $ ./scripts/utility__upgrade_dev_env.sh
#
#  Author: Pietro Arturo Panetta
#  Site: https://www.drupal.org/u/arturopanetta
#  Copyright: @arturu 2024
#  License: AGPL-3.0-only
#
################################################################################

generate_random_string() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w "${1:-5}" | head -n 1
}

random_string=$(generate_random_string 5)

echo "La stringa da ricopiare: $random_string"
read -p "Sei sicuro di voler eseguire lo script? Inserisci la stringa mostrata sopra per confermare: " user_input

if [ "$user_input" = "$random_string" ]; then
    echo "Conferma ricevuta. Procedo all'aggiornamento..."
else
    echo "La stringa non corrisponde. Non faccio nulla ed esco."
    exit 1
fi


composer update -W --no-cache
drush -y updb
drush cr
drush -y pm:install config
drush -y config:import --partial --source="$(drush drupal:directory)/modules/contrib/lexika/config/install"
drush -y config:import --partial --source="$(drush drupal:directory)/modules/contrib/bibliotheke/config/install"
drush -y config:import --partial --source="$(drush drupal:directory)/modules/contrib/prosopon/config/install"
drush -y config:import --partial --source="$(drush drupal:directory)/modules/contrib/themethla/config/install"
drush -y config:import --partial --source="$(drush drupal:directory)/modules/contrib/exesti/config/update"
drush -y config:import --partial --source="$(drush drupal:directory)/modules/contrib/sunchronizo/config/install"

drush migrate:import --update --all

drush -y config:import --partial --source="$(drush drupal:directory)/modules/contrib/prosis/config/install"
drush -y config:import --partial --source="$(drush drupal:directory)/themes/contrib/skenografia/config/update/"
drush -y updb

drush cr

echo "Aggiornamento concluso."
