#!/usr/bin/env bash

# This script performs the initial configuration of Ouitoulía.
# Run this script in the location where your composer.json is.

echo -e "\n\n-- Installo il tema ---------------------------------------------"
drush -y pm:install components big_pipe inline_form_errors responsive_image \
         easy_breadcrumb menu_link_attributes pathauto twig_tweak
drush -y theme:enable bootstrap_italia skenografia
drush -y config:set system.theme default skenografia

echo -e "\n\n-- Installo Vocabolari, Media gestiti e Configurazione utenti ---"
drush -y pm:install lexika bibliotheke prosopon

echo -e "\n\n-- Installo i campi usati dalle entità Node ---------------------"
drush -y pm:install themethla

drush -y pm:install config
# Fix node_reference module for minimal profile
drush -y config:import --partial --source="$(drush drupal:directory)/themes/contrib/bootstrap_italia/modules/bootstrap_italia_paragraph_node_reference/config/optional"
drush -y config:import --partial --source="$(drush drupal:directory)/themes/contrib/skenografia/config/update/"
drush -y pm:uninstall config

echo -e "\n\n-- Importo i dati obbligatori -----------------------------------"
drush -y pm:install sunchronizo
drush migrate:import taxonomy_common_uuid
drush migrate:import taxonomy_common
drush migrate:import scuola_roles
drush migrate:import main_menu

echo -e "\n\n-- Installo Viste, Blocchi e Permessi ---------------------------"
drush -y pm:install prosis exesti
