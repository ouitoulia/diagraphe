#!/usr/bin/env bash

# This script performs the initial configuration of Ouitoulía.
# The first parameter is a string and allows you to choose the admin password.
# If you run the script without parameters it will generate a random password.
# Use `drush uli` to get an access token.

echo "-- Installo Ouitoulía --------------------------------------------------"
drush -y site:install minimal --locale=it --account-pass=${1}

echo "-- Localizzazione in Italiano ------------------------------------------"
drush -y config:set system.date country.default IT
drush -y config:set system.date first_day 1
drush -y config:set system.date timezone.default Europe/Rome
drush -y config:set core.date_format.long pattern 'l, j F Y - H:i'
drush -y config:set core.date_format.medium pattern 'D, d/m/Y - H:i'
drush -y config:set core.date_format.short pattern 'd/m/Y - H:i'

echo "-- Imposto il numero massimo di caratteri nel sommario -----------------"
drush -y config:set text.settings default_summary_length 160

echo "-- Attivo il tema di amministrazione -----------------------------------"
drush -y theme:enable claro
drush -y config:set system.theme admin claro
drush -y config:set node.settings use_admin_theme 1
drush -y pm:install toolbar admin_toolbar admin_toolbar_tools

echo "-- Solo gli amministratori possono registrare nuovi utenti -------------"
drush -y config:set user.settings register admin_only

echo "-- Installo e configuro i moduli base ----------------------------------"
drush -y pm:install field pathauto
drush -y config:set pathauto.settings punctuation.slash 1

drush -y pm:install big_pipe datetime file field image inline_form_errors \
  media media_library node options responsive_image taxonomy telephone \
  text views

drush -y pm:install address entity_reference_display \
  entity_reference_revisions geofield imce field_group focal_point leaflet \
  office_hours paragraphs term_reference_tree

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

