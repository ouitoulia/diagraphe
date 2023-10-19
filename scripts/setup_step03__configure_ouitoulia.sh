#!/usr/bin/env bash

# This script performs the initial configuration of Ouitoulía.
# Run this script in the location where your composer.json is.

echo "-- Installo il tema ----------------------------------------------------"
drush -y pm:enable components
drush -y theme:enable bootstrap_italia skenografia
drush -y config:set system.theme default skenografia

drush -y pm:enable bootstrap_italia_image_style \
 bootstrap_italia_paragraph bootstrap_italia_paragraph_accordion \
 bootstrap_italia_paragraph_attachments bootstrap_italia_paragraph_callout \
 bootstrap_italia_paragraph_carousel bootstrap_italia_paragraph_citation \
 bootstrap_italia_paragraph_gallery bootstrap_italia_paragraph_hero \
 bootstrap_italia_paragraph_map bootstrap_italia_paragraph_node_reference \
 bootstrap_italia_paragraph_section bootstrap_italia_paragraph_timeline

drush -y pm:enable bootstrap_italia_views_accordion \
  bootstrap_italia_views_carousel bootstrap_italia_views_gallery \
  bootstrap_italia_views_list bootstrap_italia_views_timeline


echo "-- Installo i vocabolari -----------------------------------------------"
composer require ouitoulia/lexika --no-cache
drush -y en lexika

echo "-- Importo le voci di tassonomia ---------------------------------------"
composer require ouitoulia/sunchronizo_lexika --no-cache
drush -y en sunchronizo_lexika
drush migrate:import --all

echo "-- Installo i tipi di Media gestiti ------------------------------------"
composer require ouitoulia/bibliotheke --no-cache
drush -y pm:install bibliotheke

echo "-- Installo il modulo utenti -------------------------------------------"
composer require ouitoulia/prosopon --no-cache
drush -y pm:install prosopon

echo "-- Installo i campi usati dalle entità Node ----------------------------"
composer require ouitoulia/themethla --no-cache
drush -y pm:install themethla

echo "-- Importo i ruoli dell'entity 'User' ----------------------------------"
composer require ouitoulia/sunchronizo_prosopon --no-cache
drush -y pm:install sunchronizo_prosopon
drush migrate:import scuola_roles

echo "Configuro i permessi ---------------------------------------------------"
composer require ouitoulia/exesti --no-cache
drush -y pm:install exesti