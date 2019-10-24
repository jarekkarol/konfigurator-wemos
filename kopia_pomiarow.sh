#!/bin/ksh
#
# Konfigurator Wemos d1
#
# Przykładowy skrypt do wykonania kopii pomiarów z czterech sterowników
# sterowniki identyfikowane są przez nazwy mDNS lub numery ip.
# pliki kopii mają nazwy rozszerzone o daty utworzenia
# 
#

# identyfikator sterownika
controler=wemosd1pro

# katalog kopii pomiarów
backups_path=/home/pi/Backup

v_date=`date '+%Y-%m-%d'`   

wget $controler.local/data/temperatures.csv -qO $backups_path/"$controler"_temperatures_$v_date.csv
wget $controler.local/data/pressures.csv -qO $backups_path/"$controler"_pressures_$v_date.csv
wget $controler.local/data/humidites.csv -qO $backups_path/"$controler"_humidites_$v_date.csv

controler=sypialnia
wget $controler.local/data/temperatures.csv -qO $backups_path/"$controler"_temperatures_$v_date.csv

controler=pracownia
wget $controler.local/data/temperatures.csv -qO $backups_path/"$controler"_temperatures_$v_date.csv

controler=kotlownia
wget $controler.local/data/temperatures.csv -qO $backups_path/"$controler"_temperatures_$v_date.csv

at now + 10 days < /home/pi/kopia_pomiarow.sh
