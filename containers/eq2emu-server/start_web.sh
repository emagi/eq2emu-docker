cd /eq2emu/eq2emu_dawnserver/
for (( ; ; ))
do
    status=$(pidof -x "node app.js")
    if [ "$status" == '' ]; then
        git pull
		chmod +x start_login_fromweb.sh
		chmod +x start_world_fromweb.sh
		chmod +x startup.sh
		chmod +x shutdown.sh
		mv /eq2emu/eq2emu_dawnserver/eq2dawn.log /eq2emu/eq2emu_dawnserver/eq2dawn_last.log
		bash -x startup.sh
        node app.js &> /eq2emu/eq2emu_dawnserver/eq2dawn.log
		bash -x shutdown.sh
    fi
    sleep 5
done