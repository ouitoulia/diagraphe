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

get_module_status() {
    local module="$1"
    local status
    status=$(drush pm:list --format=csv | grep "($module)" | awk -F ',' '{print $(NF-1)}')
    echo "$status"
}

random_string=$(generate_random_string 5)

echo -e "\n\nLa stringa da ricopiare: $random_string"
read -p "Sei sicuro di voler eseguire lo script? Inserisci la stringa mostrata sopra per confermare: " user_input

if [ "$user_input" = "$random_string" ]; then
    echo -e "Conferma ricevuta. Procedo all'aggiornamento...\n\n"
else
    echo "La stringa non corrisponde. Non faccio nulla ed esco."
    exit 1
fi

# Salvo alcuni percorsi
drupal_dir=$(drush drupal:directory)
composer_dir=$(dirname "$drupal_dir")

# Salvo lo stato dei moduli necessari all'aggiornamento
stato_config=$(get_module_status "config")
stato_sunchronizo=$(get_module_status "sunchronizo")
stato_leaflet_views=$(get_module_status "leaflet_views")

echo -e "\n\n-- Mi sposto nella cartella dove si trova composer.json ---------"
pushd "$composer_dir" || exit 1

echo -e "\n\nAggiorno il software"
composer update -W --no-cache
drush -y updb
drush cr

# Aggiorno le configurazioni
if [ "$stato_config" == "Disabled" ]; then
  drush -y pm:install config
fi
echo "-- Aggiorno le configurazioni di lexika, bibliotheke, prosopon, themethla ed exesti."
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/lexika/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/bibliotheke/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosopon/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/themethla/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/exesti/config/update"

echo -e "\n\n-- Aggiorno gli eventuali path obsoleti -------------------------"
drush pathauto:aliases-generate update all

# Aggiorno i moduli migrate
if [ "$stato_sunchronizo" == "Enabled" ]; then
  # Se sunchronizo è attivo, disinstallo migrate così disinstalla tutte le dipendenze.
  drush -y pm:uninstall migrate
fi
# In ongi caso installo sunchronizo
drush -y pm:install sunchronizo

echo -e "\n\n-- Aggiorno la configurazione di sunchronizo --------------------"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/sunchronizo/config/install"
drush cr

echo -e "\n\n-- Aggiorno i dati obbligatori ----------------------------------"
drush migrate:import taxonomy_common_uuid
drush migrate:import taxonomy_common
drush migrate:import scuola_roles
drush migrate:import main_menu

echo -e "\n\n-- Aggiorno le configurazioni di prosis e skenografia -----------"
# Aggiorno le configurazioni
if [ "$stato_leaflet_views" == "Disabled" ]; then
  drush -y pm:install leaflet_views
fi
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosis/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosis/config/update"
drush -y config:import --partial --source="${drupal_dir}/themes/contrib/skenografia/config/update"

echo -e "\n\n-- Aggiorno il database -----------------------------------------"
drush -y updb

echo -e "\n\n-- Aggiorno le librerie del tema --------------------------------"
composer require ouitoulia/skenografia-dist:^1 --no-cache

# Cancello la cache
drush cr

echo -e "\n\n-- Aggiorno i dati facoltativi ----------------------------------"
dati_da_aggiornare=("menu_opzionali" "taxonomy_indirizzi_di_studio_infanzia" "taxonomy_indirizzi_di_studio_primaria" "taxonomy_indirizzi_di_studio_secondaria_primo_grado" "taxonomy_indirizzi_di_studio_secondaria_secondo_grado" "taxonomy_indirizzi_di_studio_universita" "taxonomy_indirizzi_di_studio_afam" "taxonomy_materie_secondaria_primo_grado" "taxonomy_materie_secondaria_secondo_grado" "taxonomy_materie_laboratori")

"${composer_dir}"/scripts/setup_step04__import_optional_data.sh $dati_da_aggiornare

echo -e "\n\n-- Disattivo i moduli che inizialmente erano disattivati --------"
if [ "$stato_config" == "Disabled" ]; then
  drush -y pm:uninstall config
fi
if [ "$stato_sunchronizo" == "Disabled" ]; then
  drush -y pm:uninstall migrate
fi

echo -e "\n\n-- Torno nella cartella da dove è stato lanciato lo script ------"
popd || exit 1

echo -e "\n\n-- Aggiornamento concluso. --\n\n"
