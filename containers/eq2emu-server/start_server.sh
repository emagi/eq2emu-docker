#!/bin/bash
sudo service mariadb start
cd /eq2emu/
if [ "$HOST_LOGIN" = "1" ]; then
    screen -d -m bash -x start_login.sh
fi
screen -d -m bash -x start_world.sh