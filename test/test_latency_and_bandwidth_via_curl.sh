#!/bin/bash
LANG=en_US.UTF-8

URL_LATENCY="http://heise.de"
URL_BANDWIDTH="http://speedtest.constant.com/10MBtest.bin"

CURL_TIME_NAMELOOKUP="--compressed -w @curl-format-time_namelookup.txt -o /dev/null -s"
CURL_TIME_CONNECT="--compressed -w @curl-format-time_connect.txt -o /dev/null -s"
CURL_BANDWIDTH="--compressed -w @curl-format-download.txt -o /dev/null -s"

FORMULA_NAMELOOKUP="scale=3; ("
FORMULA_CONNECT="scale=3; ("
for i in {1..10};do
	FORMULA_NAMELOOKUP+=`curl $CURL_TIME_NAMELOOKUP $URL_LATENCY`
	FORMULA_NAMELOOKUP+="+"
	FORMULA_CONNECT+=`curl $CURL_TIME_CONNECT $URL_LATENCY`
	FORMULA_CONNECT+="+"
done
echo "********************Average time for 10 namelookups for $URL_LATENCY"
FORMULA_NAMELOOKUP+="0)/10"
AVG_NAMELOOKUP=`echo $FORMULA_NAMELOOKUP | bc`
echo "${FORMULA_NAMELOOKUP}=${AVG_NAMELOOKUP}"
echo "********************Average time for 10 connections to $URL_LATENCY"
FORMULA_CONNECT+="0)/10"
AVG_CONNECT=`echo $FORMULA_CONNECT | bc`
echo "${FORMULA_CONNECT}=${AVG_CONNECT}"
echo "********************Download speed for $URL_BANDWIDTH"
curl $CURL_BANDWIDTH $URL_BANDWIDTH

