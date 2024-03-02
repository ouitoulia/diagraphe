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

# Salvo alcuni percorsi
drupal_dir=$(drush drupal:directory)
composer_dir=$(dirname "$drupal_dir")

# Mi sposto nella cartella dove si trova composer.json
pushd "$composer_dir" || exit 1

composer update -W --no-cache
drush -y updb
drush cr
drush -y pm:install config
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/lexika/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/bibliotheke/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosopon/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/themethla/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/exesti/config/update"

drush -y pm:uninstall migrate
drush -y pm:install sunchronizo
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/sunchronizo/config/install"
drush migrate:import --update --all

drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosis/config/install"
drush -y updb

composer require ouitoulia/skenografia-dist:^1 --no-cache

drush cr

# Torno nella cartella da dove è stato lanciato lo script
popd || exit 1

echo "Aggiornamento concluso."
