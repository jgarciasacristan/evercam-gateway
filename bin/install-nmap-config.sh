#!/bin/bash

# Ensures Nmap configuration file is present. NMAPDIR is set in environment
[ ! -d ~/.nmap ] && mkdir ~/.nmap
cp -f ../nmap-service-probes ~/.nmap
