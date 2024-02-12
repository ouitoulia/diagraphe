#!/usr/bin/env bash

# This script performs the initial configuration of Ouitoulía.
# Run this script in the location where your composer.json is.

echo "-- Installo il tema ----------------------------------------------------"
drush -y pm:install components big_pipe inline_form_errors responsive_image \
         easy_breadcrumb menu_link_attributes pathauto twig_tweak
drush -y theme:enable bootstrap_italia skenografia
drush -y config:set system.theme default skenografia

#echo "-- Configuro il text editor --------------------------------------------"
#drush -y pm:install editor ckeditor5 bootstrap_italia_text_editor2

echo "-- Installo i vocabolari -----------------------------------------------"
drush -y pm:install lexika

echo "-- Installo i tipi di Media gestiti ------------------------------------"
drush -y pm:install bibliotheke

echo "-- Installo il modulo utenti -------------------------------------------"
drush -y pm:install prosopon

echo "-- Installo i campi usati dalle entità Node ----------------------------"
drush -y pm:install themethla

drush -y pm:install config
# Fix node_reference module for minimal profile
drush -y config:import --partial --source="$(drush drupal:directory)/themes/contrib/bootstrap_italia/modules/bootstrap_italia_paragraph_node_reference/config/optional"
drush -y config:import --partial --source="$(drush drupal:directory)/themes/contrib/skenografia/config/update/"
drush -y pm:uninstall config

echo "-- Importo i dati ------------------------------------------------------"
drush -y pm:install sunchronizo
drush migrate:import --all

echo "-- Installo viste e blocchi --------------------------------------------"
drush -y pm:install prosis

echo "Configuro i permessi ---------------------------------------------------"
drush -y pm:install exesti
