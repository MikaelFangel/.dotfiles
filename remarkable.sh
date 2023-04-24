#!/bin/env bash

dev=enp0s20f0u3c2
ip link set $dev up
ip route add 10.11.99.1 dev $dev 
