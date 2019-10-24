#!/bin/ksh
#
# Konfigurator Wemos d1
#
# Przykładowy skrypt do przełaczania przekaźnika
# sterowniki identyfikowane są przez nazwy mDNS lub numery ip.
# wywołanie skryptu należy dopisać do crona w celu uzyskania harmonogramu przełaczeń
#
# wywołanie:
# /home/pi/relays.sh nazwa|Ip_sterownika Id_przekaznika operacja
#

log_file=/home/pi/relays.log
relay_on_off=0
polaczenie=1

  if [[ -z $1 ]]; 
  then
    echo "Nazwa lub numer Ip sterownika nie może być pusty."
	exit 1
  fi

  if [[ -z $2 ]]; 
  then
    echo "Identyfikator przekaźnika nie może być pusty."
	exit 1
  fi

  if [[ -z $3 ]]; 
  then
    echo "Operacja na przekaźniku nie może być pusta."
	exit 1
  fi

  relays=(relay D6 D7); 
  if [[ " "${relays[@]}" " == *" "$2" "* ]] ;then 
      #echo "$2: ok"
      :
  else 
      echo "$2: nie znany przekaźnik. Identyfikatory przekaźnika to:"
      echo "${relays[@]/%/,}"
      exit 1
  fi

  setings=(On Off); 
  if [[ " "${setings[@]}" " == *" "$3" "* ]] ;then 
      #echo "$3: ok"
      :
  else 
      echo "$3: nie znane ustawienie przekaźnika. Ustawienia przekaźnika to:"
      echo "${setings[@]/%/,}"
      exit 1
  fi
  
  relay_on_off=`wget -qO- $1/output/$2/State`

  if [[ -z "$relay_on_off" ]];
  then
    data_czas=`date '+%Y-%m-%d %H:%M:%S'`   
    echo "$data_czas Brak polaczenia z $1" >> "$log_file"
    polaczenie=0
  fi

  if test $polaczenie -eq '1' 
  then

    if [[ $3 = "Off" ]];
    then
      if [[ $relay_on_off = "On" ]]; 
      then
        sterowanie=`wget -qO- $1/output/$2/Off`
        if [[ $sterowanie = "OK" ]];
        then
          data_czas=`date '+%Y-%m-%d %H:%M:%S'`
          echo "$data_czas Przekaźnik $2 zostal wylaczony" >> "$log_file"
        fi
      fi
    fi
	
    if [[ $3 = "On" ]];
    then
      if [[ $relay_on_off = "Off" ]];
      then
        sterowanie=`wget -qO- $1/output/$2/On`
        if [[ $sterowanie = "OK" ]];
        then
          data_czas=`date '+%Y-%m-%d %H:%M:%S'`
          echo "$data_czas Przekaźnik $2 zostal wlaczony" >> "$log_file"
        fi
      fi
    fi
	
  fi
