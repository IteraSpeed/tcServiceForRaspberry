#!/bin/bash
DOWNSTREAM=1000
UPSTREAM=1000
DOWNLATENCY=0
UPLATENCY=0
UPPACKETLOSS=0
DOWNPACKETLOSS=0

usage(){
	cat <<EOF
	DESCRIPTION
		./configure_traffic_control.sh --help
		configure_traffic_control.sh OPTIONS
		Configures the traffic shaping on eth0 and wlan0.
		Both interfaces need to be configured and running
	EXAMPLE:
		configure_traffic_control.sh -d 3600 -u 1500 -o 40 -i 40 -k 2.0 -j 1
		Configures a downstream of 3600kBit/s, an upstream of 1500kBit/s and increases the latency of down- and upstream to 40ms.
	OPTIONS:
	-h
	  --help	This help
	-d	Limits the downstream by value, in kBit/s, default: 1000
	-u	Limits the upstream by value, in kBit/s, default: 1000
	-o	Sets the latency of downstream to value, in ms, default: 0
	-i	Sets the latency of upstream to value, in ms, default: 0
	-k	Sets chance of paketloss in downstream by value, in %, default: 0
	-j	Sets chance of paketloss in upsteam by value, in %, default: 0
EOF
	exit 0
}


configure_traffic_control(){
	upStreamValue="${UPSTREAM}kbit"
	upStreamLatency="${UPLATENCY}ms"
	ipNetAddress=$(/sbin/ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}.[0-9]\{1,3\}.')
	upIpNetAddress="${ipNetAddress}0/24"
	upPacketLossValue="${UPPACKETLOSS}%"
#echo 'upstream: '$upStreamValue >> /txt.file
#echo 'upstreamLatency: '$upStreamLatency
#echo 'ipAddress: '$ipNetAddress
#echo 'upstreamAddress: '$upIpNetAddress
#echo 'upPacketLoss: '$upPacketLossValue
	#eth0 - Config
	sudo tc qdisc del dev eth0 root
	sudo tc qdisc add dev eth0 root handle 1: htb default 12
	sudo tc class add dev eth0 parent 1:1 classid 1:12 htb rate $upStreamValue ceil $upStreamValue
	sudo tc qdisc add dev eth0 parent 1:12 netem delay $upStreamLatency loss $upPacketLossValue
	sudo tc filter add dev eth0 protocol ip parent 1:0 prio 1 u32 match ip src $upIpNetAddress flowid 12:1
	sudo tc filter add dev eth0 protocol ip parent 1:0 prio 2 u32 match ip src 0.0.0.0/0 match ip dst 0.0.0.0/0 flowid 11:1
	downStreamValue="${DOWNSTREAM}kbit"
	downStreamLatency="${DOWNLATENCY}ms"
	ipNetAddress=$(/sbin/ifconfig | grep -A 1 'wlan0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}.[0-9]\{1,3\}.')
	downIpNetAddress="${ipNetAddress}0/24"
	downPacketLossValue="${DOWNPACKETLOSS}%"
#echo 'downstream: '$downStreamValue
#echo 'downstreamLatency: '$downStreamLatency
#echo 'ipAddress: '$ipNetAddress
#echo 'downstreamAddress: '$downIpNetAddress
#echo 'downPacketLoss: '$downPacketLossValue
	#wlan0 - Config
	sudo tc qdisc del dev wlan0 root
	sudo tc qdisc add dev wlan0 root handle 1: htb default 12
	sudo tc class add dev wlan0 parent 1:1 classid 1:12 htb rate $downStreamValue ceil $downStreamValue
	sudo tc qdisc add dev wlan0 parent 1:12 netem delay $downStreamLatency loss $downPacketLossValue
        sudo tc filter add dev wlan0 protocol ip parent 1:0 prio 1 u32 match ip dst $downIpNetAddress flowid 12:1
	sudo tc filter add dev wlan0 protocol ip parent 1:0 prio 2 u32 match ip src 0.0.0.0/0 match ip dst 0.0.0.0/0 flowid 11:1
}

##### BEGINN DES SCRIPTS #####

if [ $# -eq 0 ]; then
	usage
fi

while [ $# -gt 0 ]
do
	case $1 in
		"-h"|"--help")
			usage
			;;
		"-d")
			shift
			DOWNSTREAM=$1
			shift
			;;
		"-u")
			shift
			UPSTREAM=$1
			shift
			;;
		"-o")
			shift
			DOWNLATENCY=$1
			shift
			;;
		"-i")
			shift
			UPLATENCY=$1
			shift
			;;
		"-k")
			shift
			DOWNPACKETLOSS=$1
			shift
			;;
		"-j")
			shift
			UPPACKETLOSS=$1
			shift
			;;
	esac
done

configure_traffic_control

exit 0
