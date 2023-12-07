#!/bin/bash

#exp1 0ms 1.5 packetloss
#reno
sysctl net.ipv4.tcp_congestion_control=reno
#setting up latency and packetloss using tc
#device name maybe be different for different instances (eth0, ens4, ens5, etc)
#use ifconfig to check
tc qdisc replace dev ens4 root netem delay 0ms loss 1.5%
iperf -t 30 -c {$MACHINE_IP} -p {$PORT}
#cubic
sysctl net.ipv4.tcp_congestion_control=cubic
iperf -t 30 -c {$MACHINE_IP} -p {$PORT}
#bbr
sysctl net.ipv4.tcp_congestion_control=bbr
iperf -t 30 -c {$MACHINE_IP} -p {$PORT}
