cd /eq2emu/eq2emu/source/LoginServer
login_update=$(git pull)
if [[ $login_update != *"Already up to date."* ]]; then
  make clean
  make -j$(nproc)
fi
cp login /eq2emu/eq2emu/server/

cd /eq2emu/eq2emu/source/WorldServer
world_update=$(git pull)
if [[ $world_update != *"Already up to date."* ]]; then
  make clean
  make -j$(nproc)
fi
cp eq2world /eq2emu/eq2emu/server/