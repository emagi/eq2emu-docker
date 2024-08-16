FROM scratch

###########################################################
# MySQL
###########################################################
# Main DB is used for eq2emu world server
ENV MARIADB_DATABASE="eq2emu"
ENV MARIADB_USER="eq2emu"
ENV MARIADB_PASSWORD="<template>"
ENV MARIADB_ROOT_PASSWORD="<template>"
ENV MYSQL_HOST="mysql"

# EQ2EMu Login Server
ENV EQ2LS_DB_HOST="mysql"
ENV EQ2LS_DB_USER="eq2ls"
ENV EQ2LS_DB_PASSWORD="<template>"
ENV EQ2LS_DB_NAME="eq2ls"
ENV EQ2LOGIN_DB_PORT=3306

# Container Web Monitor
ENV EQ2DAWN_DB_HOST="mysql"
ENV EQ2DAWN_DB_USER="eq2dawn"
ENV EQ2DAWN_DB_PASSWORD="<template>"
ENV EQ2DAWN_DB_NAME="eq2dawn_web"
ENV EQ2DAWN_DB_PORT=3306

###########################################################
# Server
###########################################################
ENV WORLD_WEBPORT=9002
ENV LOGIN_WEBPORT=9101
ENV WORLD_CLIENT_PORT=9001
ENV LOGIN_CLIENT_PORT=9100
ENV WEB_SERVER_PORT=2424
ENV DBWEB_SERVER_PORT=80

ENV WORLD_NAME="Docker Test Server"
ENV WORLD_ACCOUNT_NAME="testlabs"
ENV WORLD_ACCOUNT_PASSWORD="<template>"

ENV EQ2DAWN_ADMIN_PASSWORD="<template>"

ENV MKCERT_URL="https://github.com/FiloSottile/mkcert/releases/download/v1.4.3/mkcert-v1.4.3-linux-amd64"
ENV MKCERT_FILE="mkcert-v1.4.3-linux-amd64"

ENV WEB_CERTFILE="/eq2emu/certs/webcert.pem"
ENV WEB_KEYFILE="/eq2emu/certs/webkey.pem"
ENV WEB_CAFILE=""

ENV EQ2WORLD_WEB_ADMIN="webadmin"
ENV EQ2WORLD_WEB_PASSWORD="<template>"
ENV EQ2LOGIN_WEB_ADMIN="webadmin"
ENV EQ2LOGIN_WEB_PASSWORD="<template>"

ENV EQ2DAWN_AUTORESTART_SERVER="1"

###########################################################
# Login and World Databases to load up for first start
###########################################################
ENV EQ2WORLD_DB_PKG="https://www.zeklabs.com/dl/eq2emudb.tar.gz"
ENV EQ2WORLD_DB_FILE="eq2emudb.tar.gz"
ENV EQ2WORLD_DB_SQL="eq2emu.sql"
ENV EQ2LOGIN_DB_PKG="https://www.zeklabs.com/dl/eq2emulssql.tar.gz"
ENV EQ2LOGIN_DB_FILE="eq2emulssql.tar.gz"
ENV EQ2LOGIN_DB_SQL="eq2emulssql.sql"


###########################################################
# Sources to build from
###########################################################
ENV PREMAKE5_PKG="https://github.com/premake/premake-core/releases/download/v5.0.0-beta2/premake-5.0.0-beta2-linux.tar.gz"
ENV PREMAKE5_FILE="premake-5.0.0-beta2-linux.tar.gz"
ENV RECAST_GIT="https://github.com/recastnavigation/recastnavigation.git"
ENV FMT_GIT="https://github.com/fmtlib/fmt.git"
ENV EQ2SOURCE_GIT="https://github.com/emagi/eq2emu.git"
ENV EQ2CONTENT_GIT="https://github.com/emagi/eq2emu-content.git"
ENV EQ2MAPS_GIT="https://github.com/emagi/eq2emu-maps.git"
ENV EQ2DB_GIT="https://github.com/devn00b/EQ2EMu-DatabaseEditor.git"
ENV EQ2DAWN_GIT="https://github.com/emagi/eq2emu_dawnserver.git"


###########################################################
# Other settings
###########################################################
# The container works locally in itself, this IP address should typically be 127.0.0.1
ENV IP_ADDRESS=127.0.0.1
# This is what we will expose beyond the container for the login (default 9100), world (default 9001) and web ports (default 2424)
ENV LISTEN_PORT_ADDRESS=0.0.0.0

ENV TZ="US/Central"

ARG PUID=1000
ENV PUID=${PUID}
ARG PGID=1000
ENV PGID=${PGID}

ADD rootfs.tar.xz /

RUN apt-get update -yqq && \
    groupadd -g ${PGID} eq2emu && \
    useradd -u ${PUID} -g eq2emu -m eq2emu -G eq2emu && \
    usermod -p "*" eq2emu

RUN apt-get -y update && apt-get install -y npm nano nodejs git libnss3-tools screen jq make mariadb-client automake sudo g++ libsdl2-dev libmariadb-dev libboost-all-dev libreadline-dev cmake liblua5.3-dev lua5.3 libcrypto++-dev wget libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev libglm-dev

RUN echo "eq2emu ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

RUN mkdir -p /eq2emu && chown eq2emu:eq2emu /eq2emu

RUN chsh -s /bin/bash eq2emu 

COPY --chown=eq2emu:eq2emu install.sh /eq2emu/install.sh
COPY --chown=eq2emu:eq2emu install_web.sh /eq2emu/install_web.sh
COPY --chown=eq2emu:eq2emu compile_source.sh /eq2emu/compile_source.sh
COPY --chown=eq2emu:eq2emu update_content.sh /eq2emu/update_content.sh
COPY --chown=eq2emu:eq2emu start_server.sh /eq2emu/start_server.sh
COPY --chown=eq2emu:eq2emu start_web.sh /eq2emu/start_web.sh
COPY --chown=eq2emu:eq2emu start_login.sh /eq2emu/start_login.sh
COPY --chown=eq2emu:eq2emu start_world.sh /eq2emu/start_world.sh
COPY --chown=eq2emu:eq2emu json_write.sh /eq2emu/json_write.sh
COPY --chown=eq2emu:eq2emu ./entrypoint.pl /eq2emu/entrypoint.pl
RUN chmod +x /eq2emu/install.sh
RUN chmod +x /eq2emu/install_web.sh
RUN chmod +x /eq2emu/compile_source.sh
RUN chmod +x /eq2emu/update_content.sh
RUN chmod +x /eq2emu/start_server.sh
RUN chmod +x /eq2emu/start_web.sh
RUN chmod +x /eq2emu/start_login.sh
RUN chmod +x /eq2emu/start_world.sh
RUN chmod +x /eq2emu/json_write.sh
RUN chmod +x /eq2emu/entrypoint.pl

USER eq2emu
WORKDIR /eq2emu

EXPOSE ${WORLD_CLIENT_PORT}/udp
EXPOSE ${LOGIN_CLIENT_PORT}/udp
EXPOSE ${WEB_SERVER_PORT}/tcp
EXPOSE ${DBWEB_SERVER_PORT}/tcp
RUN /eq2emu/install.sh
ENTRYPOINT ["/bin/bash", "-c", "/eq2emu/entrypoint.pl; /bin/bash"]