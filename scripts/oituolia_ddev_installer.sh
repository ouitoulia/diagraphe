#!/bin/bash
################################################################################
#
#  Questo è uno script che installa Ouitoulìa CMS
#
#  Author: Pietro Arturo Panetta
#  Site: https://www.drupal.org/u/arturopanetta
#  Copyright: @arturu 2023
#  License: GPL-3.0-only
#
################################################################################

#-[ Impostazioni ]----------------
loggingInFile=0
notificationDisplayLevelNotice=1
notificationDisplayLevelSuccess=1
notificationDisplayLevelWarning=1
notificationDisplayLevelDanger=1
notificationDisplayLevelDebugLiv1=0
notificationDisplayLevelDebugLiv2=0
notificationDisplayLevelDebugLiv3=0


#-[ Funzioni ]--------------------
function n() { notification "$1" "$2"; } #alias di notification
function notification() {
  local message="$1"
  local level="$2"

  # Evidenziazione del testo
  if [ "$loggingInFile" = "1" ]; then
    local text_bold=``
    local text_color_red=""
    local text_color_green=""
    local text_color_yellow=""
    local text_color_blue=""
    local text_color_magenta=""
    local text_color_cyan=""
    local text_color_white=""
    local bg_red=""
    local bg_green=""
    local bg_yellow=""
    local bg_blue=""
    local bg_magenta=""
    local bg_cyan=""
    local text_reset=``
  else
    local text_bold=`tput bold`
    local text_color_red="\e[0;31m"
    local text_color_green="\e[0;32m"
    local text_color_yellow="\e[0;33m"
    local text_color_blue="\e[0;34m"
    local text_color_magenta="\e[0;35m"
    local text_color_cyan="\e[0;36m"
    local text_color_white="\e[0;97m"
    local bg_red="\e[1;41m"
    local bg_green="\e[1;42m"
    local bg_yellow="\e[1;43m"
    local bg_blue="\e[1;44m"
    local bg_magenta="\e[1;45m"
    local bg_cyan="\e[1;46m"
    local text_reset=`tput sgr0`
  fi

  local text_tag_notice=$(echo -e ${text_bold}${text_color_white}${bg_blue}[notice]${text_reset})
  local text_tag_success=$(echo -e ${text_bold}${text_color_white}${bg_green}[success]${text_reset})
  local text_tag_warning=$(echo -e ${text_bold}${text_color_white}${bg_yellow}[warning]${text_reset})
  local text_tag_danger=$(echo -e ${text_bold}${text_color_white}${bg_red}[error]${text_reset})
  local text_tag_debugLiv1=$(echo -e ${text_bold}${text_color_white}${bg_cyan}[debug L1]${text_reset})
  local text_tag_debugLiv2=$(echo -e ${text_bold}${text_color_white}${bg_cyan}[debug L2]${text_reset})
  local text_tag_debugLiv3=$(echo -e ${text_bold}${text_color_white}${bg_cyan}[debug L3]${text_reset})
  local text_tag_ask=$(echo -e ${text_bold}${text_color_white}${bg_magenta}[?]${text_reset})

  case "$level" in
    "notice")
      if [ "$notificationDisplayLevelNotice" = "1" ]; then
         echo -e "${text_tag_notice} ${message}"
      fi
    ;;

    "success")
      if [ "$notificationDisplayLevelSuccess" = "1" ]; then
         echo -e "${text_tag_success} ${message}"
      fi
    ;;

    "warning")
      if [ "$notificationDisplayLevelWarning" = "1" ]; then
         echo -e "${text_tag_warning} ${message}"
      fi
    ;;

    "danger")
      if [ "$notificationDisplayLevelDanger" = "1" ]; then
         echo -e "${text_tag_danger} ${message}"
      fi
    ;;

    "ask")
       echo -e "${text_tag_ask} ${message}"
    ;;

    "debug" | "debugLiv1")
      if [ "$notificationDisplayLevelDebugLiv1" = "1" ]; then
         echo -e "${text_tag_debugLiv1} ${message}"
      fi
    ;;

    "debugLiv2")
      if [ "$notificationDisplayLevelDebugLiv2" = "1" ]; then
         echo -e "${text_tag_debugLiv2} ${message}"
      fi
    ;;

    "debugLiv3")
      if [ "$notificationDisplayLevelDebugLiv3" = "1" ]; then
         echo -e "${text_tag_debugLiv3} ${message}"
      fi
    ;;

    *)
      echo -e "${text_tag_danger} Function notification: parametro level=\"${2}\" non valido"
    ;;
  esac

}

validate_project_name() {
  local input=$1
  local fqdn_host_regex='^[a-z][a-z0-9_-]*[a-z0-9]$'

  if [[ ! $input =~ $fqdn_host_regex ]]; then
      echo "Il nome del progetto non è nel formato corretto."
      return 1
  fi
}

echo -e "\e[0;97m\e[1;44m"
echo " ###########################"
echo "#                           #"
echo "#             🏫            #"
echo "#         Ouituolìa         #"
echo "#         installer         #"
echo "#                           #"
echo " ###########################"`tput sgr0`
echo " "


# Nome del progetto
read -r -p "Nome del progetto (fomato FQDN host) [a-z0-9] (mia-scuola): " project_name
project_name=${project_name:-mia-scuola}

while ! validate_project_name "$project_name"; do
  read -r -p "Nome del progetto (formato FQDN host) [a-z0-9] (mia-scuola): " project_name
  project_name=${project_name:-mia-scuola}
done

if [ -d "$project_name" ]; then
  echo "${project_name} already exists! Exit..."
  exit
fi

# Search project in ddev
ddev_search=$(ddev list | grep -w "$project_name" | awk '{name = $2}; END {print name}')
if [ "$project_name" == "$ddev_search" ]; then
  echo "Error! The project name ${ddev_search} already exists! Exit..."
  exit
fi

echo "Make ${project_name}"
mkdir "$project_name"
cd "$project_name" || exit

# Password di admin
read -r -p "Inserisci la password di admin [minimo 12 caratteri] (random): " adminPass
while [[ -z $adminPass || ${#adminPass} -lt 12 ]]; do
  adminPass=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 12 | head -n 1)
done

echo " "
n "Configuro ddev" notice
echo "-------------------------"
ddev config --project-type=drupal10 --docroot=web --create-docroot

echo " "
n "Avvio i container" notice
echo "----------------------------"
ddev start

echo " "
n "Scarico Drupal" notice
echo "-------------------------"

ddev composer create ouitoulia/diagraphe --no-install
ddev composer require drush/drush --no-install
ddev composer install

echo " "
n "Installo Drupal in italiano con il profilo minimal" notice
echo "-------------------------------------------------------------"
ddev exec drush -y site:install minimal --locale=it --account-pass=${adminPass}
ddev exec drush -y config:set system.date country.default IT
ddev exec drush -y config:set system.date first_day 1
ddev exec drush -y config:set system.date timezone.default Europe/Rome
ddev exec drush -y config:set "core.date_format.long pattern 'l, j F Y - H:i'"
ddev exec drush -y config:set "core.date_format.medium pattern 'D, d/m/Y - H:i'"
ddev exec drush -y config:set "core.date_format.short pattern 'd/m/Y - H:i'"

echo " "
n "Imposto il numero massimo di caratteri nel sommario" notice
echo "--------------------------------------------------------------"
ddev exec drush -y config:set text.settings default_summary_length 160

echo " "
n "Attivo il tema di amministrazione" notice
echo "--------------------------------------------"
ddev exec drush -y theme:enable claro
ddev exec drush -y config:set system.theme admin claro
ddev exec drush -y config:set node.settings use_admin_theme 1
ddev exec drush -y pm:install toolbar
ddev exec drush -y pm:install admin_toolbar admin_toolbar_tools

echo " "
n "Solo gli amministratori possono registrare nuovi utenti" notice
echo "------------------------------------------------------------------"
ddev exec drush -y config:set user.settings register admin_only

echo " "
n "Installo le dipendenze necessarie ai vocabolari" notice
echo "----------------------------------------------------------"
ddev exec drush -y pm:install field
ddev exec drush -y pm:install pathauto
ddev exec drush -y config:set pathauto.settings punctuation.slash 1

echo " "
n "Installo il tema" notice
echo "---------------------------"
ddev exec drush -y pm:enable components big_pipe inline_form_errors responsive_image
ddev exec drush -y theme:enable bootstrap_italia
ddev exec drush -y theme:enable skenografia
ddev exec drush -y config:set system.theme default skenografia

echo " "
n "Installo i vocabolari" notice
echo "--------------------------------"
ddev composer require ouitoulia/lexika --no-cache
ddev exec drush -y en lexika

echo " "
n "Importo le voci di tassonomia" notice
echo "----------------------------------------"
ddev composer require ouitoulia/sunchronizo_lexika --no-cache
ddev exec drush -y en sunchronizo_lexika
ddev exec drush migrate:import --all

echo " "
n "Installo le configurazioni di 'Media'" notice
echo "--------------------------------------------------"
ddev exec drush -y pm:install file image media media_library
ddev composer require ouitoulia/bibliotheke --no-cache
ddev exec drush -y pm:install bibliotheke

echo " "
n "Installo il tipo di contenuto 'Persona'" notice
echo "--------------------------------------------------"
ddev exec drush -y pm:install datetime field file image options text telephone views field_group
ddev composer require ouitoulia/prosopon --no-cache
ddev exec drush -y pm:install prosopon

echo " "
n "Importo i ruoli associati al tipo 'Persona'" notice
echo "------------------------------------------------------"
ddev composer require ouitoulia/sunchronizo_prosopon --no-cache
ddev exec drush -y pm:install sunchronizo_prosopon
ddev exec drush migrate:import scuola_roles

echo " "
n "Pulizia" notice
echo "------------------"
#dev exec drush -y pm:uninstall sunchronizo_lexika lexika migrate dblog bibliotheke
#ddev composer remove ouitoulia/sunchronizo_lexika ouitoulia/lexika ouitoulia/bibliotheke

#ddev ssh
ddev describe
echo "La password di admin è: ${adminPass}"