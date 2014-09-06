#!/bin/bash

#core shell script/service to mirror Mac printers to Airprint


## Get Computername
ComputerName=`scutil --get ComputerName`

## Get all bonjour printers for printers belonging to $ComputerName and print to file "/tmp/printerlist.txt"
dns-sd -B _ipp._tcp local | colrm 1 73 > /tmp/printerlist.txt & sleep 1 & killall dns-sd
cat /tmp/printerlist.txt | grep -v 'Instance Name' | sort | uniq | grep ${ComputerName} > /tmp/printerlist.txt

#SAVEIFS=$IFS
#IFS=$(echo -en "\n\b")

## List printers
printers=`cat /tmp/printerlist.txt`

## For each printer listed, Get the dns-sd full details and print them to file as titled by the printer name.
## Adds the urf format and "transparent=T binary=T" settings which I believe are needed

for i in $printers; do
txt=`echo "$i" | sed 's/\ /+/g'`
echo $i;
echo $txt;
dns-sd -L "$i" _ipp._tcp local > /tmp/"$i"  & sleep 1 & killall dns-sd
Options=`cat /tmp/"$i" | grep 'product=' | tr -d \'\\\\\(\) | sed "s@pwg-raster@urf URF=W8,CP1,RS300-600,DM3,SRGB24@g" | sed "s/$/ transparent=T binary=T/" | sed 's/note.*priority/note= priority/g' | uniq`
echo $Options;
dns-sd -R "$i""2" _ipp._tcp,_universal . 631 $Options & sleep 1 &
done

for i in $printers; do
IFS=$(echo -en "\n\b")
Options=`cat /tmp/"$i"`
IFS=$SAVEIFS
dns-sd -R "$i""2" _ipp._tcp,_universal . 631 $Options & sleep 1 &
done










#alias TheCommand="dns-sd -R "\"\$i"\" _ipp._tcp,_universal . 631 "$Options" & unalias TheCommand"

#for i in $printers; do
#Options=`cat "$i"`

#TheCommand 

#done



#IFS=$SAVEIFS



#for i in $printers; do
#Options=`cat "$i"`

#dns-sd -R "$i" _ipp._tcp,_universal . 631 $Options & sleep 0 &

#done



