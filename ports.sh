#!/usr/bin/env bash 
nmapscan(){
  while read line;do
    line=$(echo $line | sed 's/,/|/')
    line=$(echo $line | sed 's/"//g')
    server=$(echo $line | awk -F'|' '{print $1}')
    port=$(echo $line | awk -F'|' '{print $2}')
    nmap -oN salida.txt --append-output  -p $port $server -Pn 
  done < $1
}
document(){
  origen=$(hostname)
  file=$(hostname)_scan_$(date +%Y%m%d%H%M%S).csv
  echo "Origen,Destination,Port,Protocol,Service,State">$file
  while read line;do
	  if [ $(echo $line | grep -c 'report for') != 0 ];then
	      server=$(echo $line | awk '{print $5}' )
      elif [ $(echo $line | grep -cE "tcp|udp") != 0 ];then 
              port=$(echo $line | awk -F'/' '{print $1}')
	      protocol=$(echo $line | awk -F '/' '{print $2}' )
	      protocol=$(echo $protocol | awk '{print $1}')
	      service=$(echo $line | awk '{print $3}')
	      state=$(echo $line | awk '{print $2}')
	      echo "$origen,$server,$port,$protocol,$service,$state">>$file
	  fi
  done < salida.txt
  rm salida.txt
}
main(){
  nmapscan $1 
  document
}
main $1
