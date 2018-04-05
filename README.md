# Wi-Fi Scanner

## Introduction
This project contains code for a simple wi-fi network scanner, which operates in monitor mode and gathers information about signal strength, MAC addresses and time of each packet it sees using tcpdump utility. After scanning for some time it automatically uploads the results to some specified remote server and starts again.

## Project structure
It consists of several files:
* program.lua - main file, which is to be compiled and run
* scanner.lua - contains code for the scanner itself
* ssh_conn.lua - set of necessary features to establish connection with a remote server and send files to it
* config_templ.lua - template for a config file; how-to is placed inside

## Requirements
* machine's wireless network card must support monitor mode
* to use on OpenWRT OS you must:
  * install ssh-keygen utility - comes with openssh-keygen packet
  * install openssh-client packet
  * configure your network card's monitor interface as the following article suggests: https://wiki.openwrt.org/doc/howto/wireless.tool.aircrack-ng
