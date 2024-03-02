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

# Aggiorno i moduli
composer update -W --no-cache
drush -y updb
drush cr

# Aggiorno le configurazioni
drush -y pm:install config
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/lexika/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/bibliotheke/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosopon/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/themethla/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/exesti/config/update"

# Aggiorno i moduli migrate
drush -y pm:uninstall migrate
drush -y pm:install sunchronizo
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/sunchronizo/config/install"
drush migrate:import taxonomy_common_uuid
drush migrate:import taxonomy_common
drush migrate:import scuola_roles
drush migrate:import main_menu

# Aggiorno le configurazioni
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosis/config/install"
drush -y config:import --partial --source="${drupal_dir}/themes/contrib/skenografia/config/update"

# Aggiorno il db
drush -y updb

# Aggiorno le librerie del tema
composer require ouitoulia/skenografia-dist:^1 --no-cache

# Cancello la cache
drush cr

# Aggiorno i dati facoltativi
dati_da_aggiornare=("taxonomy_indirizzi_di_studio_infanzia" "taxonomy_indirizzi_di_studio_primaria" "taxonomy_indirizzi_di_studio_secondaria_primo_grado" "taxonomy_indirizzi_di_studio_secondaria_secondo_grado" "taxonomy_indirizzi_di_studio_universita" "taxonomy_indirizzi_di_studio_afam" "taxonomy_materie_secondaria_primo_grado" "taxonomy_materie_secondaria_secondo_grado" "taxonomy_materie_laboratori")

"${composer_dir}"/scripts/setup_step04__import_optional_data.sh "$dati_da_aggiornare"

# Disattivo i moduli
drush -y pm:uninstall migrate
drush -y pm:uninstall config

# Torno nella cartella da dove è stato lanciato lo script
popd || exit 1

echo "Aggiornamento concluso."
