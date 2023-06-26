#!/usr/bin/env bash

# $1 = Ouitoulía version
# ^10, ^10.1, ecc

#composer create ouitoulia/diagraphe:${1} --no-install --no-cache

composer require drush/drush --no-install
composer install