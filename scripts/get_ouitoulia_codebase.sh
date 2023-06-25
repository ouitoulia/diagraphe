#!/usr/bin/env bash

composer create ouitoulia/diagraphe:${1} --no-install --no-cache
composer require drush/drush --no-install
composer install