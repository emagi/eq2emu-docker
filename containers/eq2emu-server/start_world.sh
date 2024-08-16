cd /eq2emu/eq2emu/server/
status=$(pidof -x "eq2world")
if [ "$status" == '' ]; then
	mv /eq2emu/eq2emu/server/logs/eq2world.log /eq2emu/eq2emu/server/logs/eq2world_last.log
	./eq2world &> /eq2emu/eq2emu/server/logs/eq2world.log
fi