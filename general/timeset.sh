#!/bin/sh

service ntp stop
ntpd -gq
service ntp start
