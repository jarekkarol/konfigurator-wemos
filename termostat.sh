#!/bin/ksh
#
# Konfigurator Wemos d1
# Przykładowy skrypt realizujący funkcję termostatu
#
# tu niezbędna powłoka ksh bo może operować na float
#
# Automatyczne uruchamianie skryptu /home/pi/termostat.sh w Raspberrypi przez dopisanie do rc.local:
#cd /etc
#sudo nano rc.local
# dopisać przed exit 0
#
#echo "8.0" > /home/pi/temp_zadana
#su - pi -c  'nohup /home/pi/termostat.sh & '

ip_termometru=sypialnia.local
ip_przekaznika=kotlownia.local
temperatura_zadana=18.0
histereza=0.5
plik_logu=/home/pi/termostat.log
piec_on_off=0

data_czas=`date '+%Y-%m-%d %H:%M:%S'`   
echo "$data_czas ----------------------" >> "$plik_logu"
echo "$data_czas   Start termostat.sh" >> "$plik_logu"
echo "$data_czas ----------------------" >> "$plik_logu"

while true 
do 

  polaczenie=1

  temperatura_zadana=`cat /home/pi/temp_zadana`

  # odczyt temperatury ze sterownika 
  temperatura=`wget -qO- $ip_termometru/sensor/temperature0`

  if test -z "$temperatura"
  then
    data_czas=`date '+%Y-%m-%d %H:%M:%S'`   
    echo "$data_czas Brak polaczenia z $ip_termometru" >> "$plik_logu"
    polaczenie=0
  fi

  #echo "temperatura: $temperatura C"

  if [[ $temperatura = "Brak termometru" ]];
  then
    data_czas=`date '+%Y-%m-%d %H:%M:%S'`    
    echo "$data_czas Brak termometru pod adresem: $ip_termometru/sensor/temperature0" >> "$plik_logu"
    polaczenie=0
  fi


  piec_on_off=`wget -qO- $ip_przekaznika/output/relay/State`

  if test -z "$piec_on_off"
  then
    data_czas=`date '+%Y-%m-%d %H:%M:%S'`   
    echo "$data_czas Brak polaczenia z $ip_przekaznika" >> "$plik_logu"
    polaczenie=0
  fi

  if test $polaczenie -eq '1' 
  then

    # konwersja typu
    temperatura=$(( temperatura + 0))

if test $temperatura -gt $(( temperatura_zadana + histereza ))
then
  if [[ $piec_on_off = "On" ]]; 
  then
    data_czas=`date '+%Y-%m-%d %H:%M:%S'`
    echo "$data_czas Temperatura: $temperatura C jest wieksza od $(( temperatura_zadana + histereza ))" >> "$plik_logu"
    sterowanie=`wget -qO- $ip_przekaznika/output/relay/Off`
    if [[ $sterowanie = "OK" ]];
    then
      data_czas=`date '+%Y-%m-%d %H:%M:%S'`
      echo "$data_czas Piec zostal wylaczony" >> "$plik_logu"
    fi
  fi
fi

if test $temperatura -lt $(( temperatura_zadana - histereza ))
then
  if [[ $piec_on_off = "Off" ]];
  then
    data_czas=`date '+%Y-%m-%d %H:%M:%S'`    
    echo "$data_czas Temperatura: $temperatura C jest mniejsza od $(( temperatura_zadana - histereza ))" >> "$plik_logu"
    sterowanie=`wget -qO- $ip_przekaznika/output/relay/On`
    if [[ $sterowanie = "OK" ]];
    then
      data_czas=`date '+%Y-%m-%d %H:%M:%S'`
      echo "$data_czas Piec zostal wlaczony" >> "$plik_logu"
    fi
  fi
fi

fi

   sleep 120
done