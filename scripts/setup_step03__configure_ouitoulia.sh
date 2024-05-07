#!/usr/bin/env sh

# This script performs the initial configuration of Ouitoulía.
# Run this script in the location where your composer.json is.

printf "\n\n-- Installo il tema base -----------------------------------------\n"
drush -y pm:install ajax_loader components big_pipe inline_form_errors \
          responsive_image easy_breadcrumb menu_link_attributes pathauto twig_tweak
drush -y theme:enable bootstrap_italia

printf "\n\n-- Installo Vocabolari, Media gestiti e Configurazione utenti ----\n"
drush -y pm:install bibliotheke
drush -y pm:install lexika prosopon

printf "\n\n-- Installo i campi usati dalle entità Node ----------------------\n"
drush -y pm:install themethla

printf "\n\n-- Installo il sub-theme -----------------------------------------\n"
drush -y theme:enable skenografia
drush -y config:set system.theme default skenografia

drush -y pm:install config
# Fix node_reference module for minimal profile
drush -y config:import --partial --source="$(drush drupal:directory)/themes/contrib/bootstrap_italia/modules/bootstrap_italia_paragraph_node_reference/config/optional"
drush -y config:import --partial --source="$(drush drupal:directory)/themes/contrib/skenografia/config/update/"

printf "\n\n-- Importo i dati obbligatori ------------------------------------\n"
drush -y pm:install sunchronizo
drush migrate:import taxonomy_common_uuid
drush migrate:import taxonomy_common
drush migrate:import scuola_roles
drush migrate:import main_menu

printf "\n\n-- Installo Viste, Blocchi e Permessi ----------------------------\n"
drush -y pm:install prosis exesti
drush -y config:import --partial --source="$(drush drupal:directory)/modules/contrib/prosis/config/update/"

printf "\n\n-- Installo il modulo di ricerca ---------------------------------\n"
drush -y pm:install anazetesis

drush -y pm:uninstall config
