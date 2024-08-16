#!/bin/bash
sudo service mariadb start
cd /eq2emu/
screen -d -m bash -x start_login.sh
screen -d -m bash -x start_world.sh