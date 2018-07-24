#!/bin/sh
a="/$0"; a=${a%/*}; a=${a:-.}; a=${a#/}/; 
cd "$a" || exit 1

./translation-scan.pl . > ./translation/templates/unlocker.pot
./translation-update.pl .