cd /eq2emu/eq2emu/server/
status=$(pidof -x "login")
if [ "$status" == '' ]; then
	mv /eq2emu/eq2emu/server/logs/eq2login.log /eq2emu/eq2emu/server/logs/eq2login_last.log
	./login &> /eq2emu/eq2emu/server/logs/eq2login.log
fi