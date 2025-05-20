#!/bin/bash
./rootfs.sh
cp output/rootfs-alpine.tar.gz .
./system.sh -f rootfs-alpine.tar.gz -d pico-pro-max