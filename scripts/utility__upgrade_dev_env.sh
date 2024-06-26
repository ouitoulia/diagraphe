#!/usr/bin/env sh
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

random_string=$(openssl rand -base64 6 | tr -dc 'a-zA-Z0-9' | head -c 5)

printf "\n\nLa stringa da ricopiare: %s\n" "$random_string"
printf "\nSei sicuro di voler eseguire lo script? Inserisci la stringa mostrata sopra per confermare: "
read -r user_input

if [ "$user_input" = "$random_string" ]; then
    printf "Conferma ricevuta. Procedo all'aggiornamento...\n\n"
else
    printf "La stringa non corrisponde. Non faccio nulla ed esco."
    exit 1
fi

# Salvo alcuni percorsi
drupal_dir=$(drush drupal:directory)
composer_dir=$(dirname "$drupal_dir")
current_path=$(pwd)

# Salvo lo stato dei moduli necessari all'aggiornamento
stato_config=$(drush pm:list --format=csv | grep "(config)" | awk -F ',' '{print $(NF-1)}')
stato_sunchronizo=$(drush pm:list --format=csv | grep "(sunchronizo)" | awk -F ',' '{print $(NF-1)}')

printf "\n\n-- Mi sposto nella cartella dove si trova composer.json ----------"

cd "$composer_dir" || exit 1

# Check sulla versione di drupal
# formato major.minor.patch
drupal_version=$(composer show drupal/recommended-project | grep 'versions :' | awk '{print $NF}')

# formato major.minor
drupal_version_minor=$(echo "$drupal_version" | awk -F. '{print $1"."$2}')

if [ "$drupal_version_minor" != "10.3" ]; then
  echo "Questo script funziona solo con drupal 10.3 stai usando $drupal_version_minor"
  exit 1
fi

printf "\n\nAggiorno il software\n"
composer update -W --no-cache
drush -y updb
drush cr

# Check sui moduli Ouitoulía
# Estrae la versione corrente di ouitoulia/themethla
themethla_version=$(composer show ouitoulia/themethla | grep 'versions :' | awk '{print $NF}' | awk -F. '{print $1}')

# Verifica se la versione corrente è inferiore a 4
if [ "$themethla_version" -lt 4 ]; then
  echo "La versione corrente di ouitoulia/themethla è inferiore a 4. Eseguo il comando composer require..."
  composer require ouitoulia/themethla:^4 ouitoulia/exesti:^2 ouitoulia/prosis:^2 ouitoulia/sunchronizo:^3 -W
fi

# Aggiorno le configurazioni
if [ "$stato_config" != "Enabled" ]; then
  drush -y pm:install config
fi
printf "\n\n-- Aggiorno le configurazioni di lexika, bibliotheke, prosopon, themethla ed exesti.\n"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/lexika/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/bibliotheke/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosopon/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/themethla/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/exesti/config/update"

printf "\n\n-- Aggiorno gli eventuali path obsoleti --------------------------\n"
drush pathauto:aliases-generate update all

# Aggiorno i moduli migrate
if [ "$stato_sunchronizo" = "Enabled" ]; then
  # Se sunchronizo è attivo, disinstallo migrate così disinstalla tutte le dipendenze.
  drush -y pm:uninstall migrate
fi
# In ogni caso installo sunchronizo
drush -y pm:install sunchronizo

printf "\n\n-- Aggiorno la configurazione di sunchronizo ---------------------\n"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/sunchronizo/config/install"
drush cr

printf "\n\n-- Aggiorno i dati obbligatori -----------------------------------\n"
drush migrate:import taxonomy_common_uuid
drush migrate:import taxonomy_common
drush migrate:import scuola_roles
drush migrate:import main_menu

printf "\n\n-- Aggiorno le configurazioni di prosis e skenografia ------------\n"
composer require ouitoulia/skenografia:^2 --no-cache

# Aggiorno le configurazioni
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosis/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/prosis/config/update"
drush -y config:import --partial --source="${drupal_dir}/themes/contrib/skenografia/config/install"
drush -y config:import --partial --source="${drupal_dir}/themes/contrib/skenografia/config/update"

printf "\n\n-- Aggiorno il database ------------------------------------------\n"
drush -y updb

printf "\n\n-- Aggiorno le librerie del tema ---------------------------------\n"
composer require ouitoulia/skenografia-dist:^2 --no-cache

# Cancello la cache
drush cr

printf "\n\n-- Aggiorno i dati facoltativi -----------------------------------\n"
dati_da_aggiornare="menu_opzionali taxonomy_indirizzi_di_studio_infanzia taxonomy_indirizzi_di_studio_primaria taxonomy_indirizzi_di_studio_secondaria_primo_grado taxonomy_indirizzi_di_studio_secondaria_secondo_grado taxonomy_indirizzi_di_studio_universita taxonomy_indirizzi_di_studio_afam taxonomy_materie_infanzia taxonomy_materie_primaria taxonomy_materie_secondaria_primo_grado taxonomy_materie_secondaria_secondo_grado taxonomy_materie_laboratori"

"${composer_dir}"/scripts/setup_step04__import_optional_data.sh "$dati_da_aggiornare"

printf "\n\n-- Aggiorno il modulo di ricerca ---------------------------------\n"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/anazetesis/config/install"
drush -y config:import --partial --source="${drupal_dir}/modules/contrib/anazetesis/config/optional"
drush cr
drush cron -y

printf "\n\n-- Disattivo i moduli config e sunchronizo se erano disattivati --\n"
if [ "$stato_config" = "Disabled" ]; then
  drush -y pm:uninstall config
fi
if [ "$stato_sunchronizo" = "Disabled" ]; then
  drush -y pm:uninstall migrate
fi

printf "\n\n-- Torno nella cartella da dove è stato lanciato lo script -------\n"
cd "$current_path" || exit 1

printf "\n\n-- Aggiornamento concluso. --\n\n"
