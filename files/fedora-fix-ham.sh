#!/bin/bash
set -x

sudo setenforce 0
sudo usermod -aG dialout $USER
pactl list sources short | grep -i xiegu

