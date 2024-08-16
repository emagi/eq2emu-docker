#!/usr/bin/perl

#############################################
# vars
#############################################
my $EQ2DAWN_ADMIN_PASSWORD = $ENV{'EQ2DAWN_ADMIN_PASSWORD'};
my $EQ2DAWN_DB_USER = $ENV{'EQ2DAWN_DB_USER'};
my $EQ2DAWN_DB_PASSWORD = $ENV{'EQ2DAWN_DB_PASSWORD'};
my $EQ2DAWN_DB_HOST = $ENV{'EQ2DAWN_DB_HOST'};
my $EQ2LS_DB_PASSWORD = $ENV{'EQ2LS_DB_PASSWORD'};
my $EQ2DAWN_AUTORESTART_SERVER = $ENV{'EQ2DAWN_AUTORESTART_SERVER'};

my $EQ2DAWN_DB_NAME = $ENV{'EQ2DAWN_DB_NAME'};
my $EQ2LS_DB_NAME = $ENV{'EQ2LS_DB_NAME'};
my $EQ2LS_DB_USER = $ENV{'EQ2LS_DB_USER'};
my $EQ2LS_DB_HOST = $ENV{'EQ2LS_DB_HOST'};

my $MYSQL_PASSWORD = $ENV{'MYSQL_PASSWORD'};
my $MYSQL_USER = $ENV{'MYSQL_USER'};
my $MYSQL_DATABASE = $ENV{'MYSQL_DATABASE'};
my $MYSQL_HOST = $ENV{'MYSQL_HOST'};


my $IP_ADDRESS = $ENV{'IP_ADDRESS'};
my $WORLD_WEBPORT = $ENV{'WORLD_WEBPORT'};
my $LOGIN_WEBPORT = $ENV{'LOGIN_WEBPORT'};
my $WEB_CERTFILE = $ENV{'WEB_CERTFILE'};
my $WEB_KEYFILE = $ENV{'WEB_KEYFILE'};
my $WEB_CAFILE = $ENV{'WEB_CAFILE'};

my $WEB_SERVER_PORT = $ENV{'WEB_SERVER_PORT'};

my $WORLD_CLIENT_PORT = $ENV{'WORLD_CLIENT_PORT'};
my $LOGIN_CLIENT_PORT = $ENV{'LOGIN_CLIENT_PORT'};

my $WORLD_NAME = $ENV{'WORLD_NAME'};
my $WORLD_ACCOUNT_NAME = $ENV{'WORLD_ACCOUNT_NAME'};
my $WORLD_ACCOUNT_PASSWORD = $ENV{'WORLD_ACCOUNT_PASSWORD'};

my $EQ2WORLD_WEB_ADMIN = $ENV{'EQ2WORLD_WEB_ADMIN'};
my $EQ2WORLD_WEB_PASSWORD = $ENV{'EQ2WORLD_WEB_PASSWORD'};
my $EQ2LOGIN_WEB_ADMIN = $ENV{'EQ2LOGIN_WEB_ADMIN'};
my $EQ2LOGIN_WEB_PASSWORD = $ENV{'EQ2LOGIN_WEB_PASSWORD'};

my $MYSQL_ROOT_PASSWORD = $ENV{'MYSQL_ROOT_PASSWORD'};
	
use strict;
use warnings;
use File::Copy;
use Config::IniFiles;

# Function to modify and save an INI file
sub modify_ini_file {
    my ($source_file, $destination_file, $section, $params) = @_;

    # Load the existing .ini file
    my $cfg = Config::IniFiles->new(-file => $source_file);

    # Check if the file was loaded successfully
    unless ($cfg) {
        die "Could not load $source_file: ", Config::IniFiles->errstr;
    }

    # Update or add new values in the specified section
    foreach my $key (keys %$params) {
        $cfg->newval($section, $key, $params->{$key});
    }

    # Save the modified configuration to the destination file
    $cfg->WriteConfig($destination_file);

    print "INI file modified and saved to: $destination_file\n";
}


sub copy_file_if_not_exists {
    my ($source_file, $target_file) = @_;

    # Check if the target file exists
    if (-e $target_file) {
        print "Target file already exists. No action taken.\n";
        return 0;  # Return 0 if the target file exists
    } else {
        if (copy($source_file, $target_file)) {
            print "File copied successfully.\n";
            return 1;  # Return 1 if the file was successfully copied
        } else {
            die "Failed to copy file: $!";
        }
    }
}

qx{touch "/eq2emu/server_loading"};

#############################################
# time
#############################################
print "# Setting timezone\n";
print `sudo rm /etc/localtime`;
print `sudo ln -s /usr/share/zoneinfo/\$TZ /etc/localtime`;

my $login_params = {
    'host'     => $EQ2LS_DB_HOST,
    'user'     => $EQ2LS_DB_USER,
    'password' => $EQ2LS_DB_PASSWORD,
    'database' => $EQ2LS_DB_NAME
};

modify_ini_file('/eq2emu/eq2emu/server/login_db.ini.example', '/eq2emu/eq2emu/server/login_db.ini', 'Database', $login_params);

my $world_params = {
    'host'     => $MYSQL_HOST,
    'user'     => $MYSQL_USER,
    'password' => $MYSQL_PASSWORD,
    'database' => $MYSQL_DATABASE
};

modify_ini_file('/eq2emu/eq2emu/server/world_db.ini.example', '/eq2emu/eq2emu/server/world_db.ini', 'Database', $world_params);

my $res = copy_file_if_not_exists("/eq2emu/eq2emu/server/log_config.xml.example", "/eq2emu/eq2emu/server/log_config.xml");


if (-e "startup.sql") {
	print "startup.sql file exists, skipping Dawn Web instantiation.\n";
}
else {
		print "# Setting up EQ2Emu Dawn Web Server...\n";
		qx{rm webserver+3.pem};
		qx{rm webserver+3-key.pem};
		my $out = qx{mkcert --version};
		print "$out";
		my $mkcertinstall = qx{mkcert -install};
		print "$mkcertinstall";
		my $mkcertroot = qx{mkcert -CAROOT};
		print "$mkcertroot";
		my $mkcertfile = qx{mkcert webserver localhost $IP_ADDRESS ::1};
		print "$mkcertfile";
		qx{mv -f webserver+3.pem /eq2emu/certs/webcert.pem};
		qx{mv -f webserver+3-key.pem /eq2emu/certs/webkey.pem};
		qx{rm /eq2emu/startup.sql};
		my $tables = "CREATE DATABASE IF NOT EXISTS " . $EQ2LS_DB_NAME . ";\nCREATE DATABASE IF NOT EXISTS " . $EQ2DAWN_DB_NAME . ";\n";
		my $users = 'CREATE USER IF NOT EXISTS \'' . $EQ2DAWN_DB_USER . '\'@\'%\' IDENTIFIED BY \'' . $EQ2DAWN_DB_PASSWORD . "';\nCREATE USER IF NOT EXISTS \'" . $EQ2LS_DB_USER . '\'@\'%\' IDENTIFIED BY \'' . $EQ2LS_DB_PASSWORD . "';\n";
		my $grantdawn = "GRANT ALL PRIVILEGES ON " . $EQ2DAWN_DB_NAME . '.* TO \'' . $EQ2DAWN_DB_USER . '\'@\'%\' with grant option;' . "\n";
		my $grantls = "GRANT ALL PRIVILEGES ON " . $EQ2LS_DB_NAME . '.* TO \'' . $EQ2LS_DB_USER . '\'@\'%\' with grant option;' . "\n";
		my $web_table = "\nuse " . $EQ2DAWN_DB_NAME . ";\nCREATE TABLE IF NOT EXISTS users (id INT AUTO_INCREMENT PRIMARY KEY, username VARCHAR(255) NOT NULL UNIQUE, password VARCHAR(128) NOT NULL, salt VARCHAR(32) NOT NULL, role ENUM('admin', 'moderator', 'user') NOT NULL DEFAULT 'user' );\n";
		open(my $fh, '>', "startup.sql") or die "Could not open file 'startup.sql'";
		print $fh $tables;
		print $fh $users;
		print $fh $grantdawn;
		print $fh $grantls;
		print $fh $web_table;
		close $fh;
		qx{mysql -uroot -hmysql -p"$MYSQL_ROOT_PASSWORD" < startup.sql};
}
my @output = `/usr/bin/node /eq2emu/eq2emu_dawnserver/generateUserQuery.js --username admin --password \"$EQ2DAWN_ADMIN_PASSWORD\" --role admin > dawn.sql`;
qx{bash -x /eq2emu/install_web.sh};
qx{mysql -u"$EQ2DAWN_DB_USER" -h"$EQ2DAWN_DB_HOST" -p"$EQ2DAWN_DB_PASSWORD" "$EQ2DAWN_DB_NAME" < dawn.sql};
qx{rm dawn.sql};

qx{mkdir -p /eq2emu/eq2emu/server/logs};

qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json.example /eq2emu/eq2emu_dawnserver/dawn_config.json .mysql.password "$EQ2DAWN_DB_PASSWORD"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .mysql.user "$EQ2DAWN_DB_USER"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .mysql.host "$EQ2DAWN_DB_HOST"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .mysql.database "$EQ2DAWN_DB_NAME"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .http.port "$WEB_SERVER_PORT"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .http.auto_restart "$EQ2DAWN_AUTORESTART_SERVER"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .http.server_key "$WEB_KEYFILE"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .http.server_cert "$WEB_CERTFILE"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .http.server_ca "$WEB_CAFILE"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .polling.login_admin "$EQ2LOGIN_WEB_ADMIN"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .polling.login_password "$EQ2LOGIN_WEB_PASSWORD"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .polling.world_admin "$EQ2WORLD_WEB_ADMIN"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu_dawnserver/dawn_config.json /eq2emu/eq2emu_dawnserver/dawn_config.json .polling.world_password "$EQ2WORLD_WEB_PASSWORD"};

print "# Starting up EQ2Emu Dawn Web Server...\n";
qx{screen -d -m bash -x start_web.sh};


print "# Configuring Login and World Server...\n";
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json.example /eq2emu/eq2emu/server/server_config.json .LoginServer.loginserver "$IP_ADDRESS"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginServer.worldaddress "$IP_ADDRESS"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginServer.internalworldaddress "$IP_ADDRESS"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginServer.loginport "$LOGIN_CLIENT_PORT"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginServer.worldname "$WORLD_NAME"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginServer.account "$WORLD_ACCOUNT_NAME"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginServer.password "$WORLD_ACCOUNT_PASSWORD"};

qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginServer.worldport "$WORLD_CLIENT_PORT"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .WorldServer.webaddress "$IP_ADDRESS"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .WorldServer.webport "$WORLD_WEBPORT"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .WorldServer.webcertfile "$WEB_CERTFILE"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .WorldServer.webkeyfile "$WEB_KEYFILE"};

qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginConfig.ServerPort "$LOGIN_CLIENT_PORT"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginConfig.webloginaddress "$IP_ADDRESS"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginConfig.webloginport "$LOGIN_WEBPORT"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginConfig.webcertfile "$WEB_CERTFILE"};
qx{bash -x /eq2emu/json_write.sh /eq2emu/eq2emu/server/server_config.json /eq2emu/eq2emu/server/server_config.json .LoginConfig.webkeyfile "$WEB_KEYFILE"};

print "# Server Starting Up... visit https://$IP_ADDRESS:$WEB_SERVER_PORT and use login credentials user: admin password: $EQ2DAWN_ADMIN_PASSWORD to establish when login and world server are online.\n";

if (-e "first_install") {
	print "First install file exists, skipping DB instantiation.\n";
}
else {
	print "# New database install, please wait...\n";
	my $EQ2WORLD_DB_PKG = $ENV{'EQ2WORLD_DB_PKG'};
	my $EQ2LOGIN_DB_PKG = $ENV{'EQ2LOGIN_DB_PKG'};
	my $EQ2WORLD_DB_FILE = $ENV{'EQ2WORLD_DB_FILE'};
	my $EQ2LOGIN_DB_FILE = $ENV{'EQ2LOGIN_DB_FILE'};
	my $EQ2WORLD_DB_SQL = $ENV{'EQ2WORLD_DB_SQL'};
	my $EQ2LOGIN_DB_SQL = $ENV{'EQ2LOGIN_DB_SQL'};
	qx{rm "$EQ2LOGIN_DB_FILE"};
	qx{rm "$EQ2LOGIN_DB_SQL"};
	qx{wget "$EQ2LOGIN_DB_PKG"};
	qx{tar -xzvf $EQ2LOGIN_DB_FILE};
	qx{mysql -u"$EQ2LS_DB_USER" -h"$EQ2LS_DB_HOST" -p"$EQ2LS_DB_PASSWORD" "$EQ2LS_DB_NAME" < "$EQ2LOGIN_DB_SQL"};
	
	qx{mysql -u"$EQ2LS_DB_USER" -h"$EQ2LS_DB_HOST" -p"$EQ2LS_DB_PASSWORD" "$EQ2LS_DB_NAME" -e"insert into web_users set username='$EQ2LOGIN_WEB_ADMIN',passwd=sha2('$EQ2LOGIN_WEB_PASSWORD',512);"};
	qx{mysql -u"$EQ2LS_DB_USER" -h"$EQ2LS_DB_HOST" -p"$EQ2LS_DB_PASSWORD" "$EQ2LS_DB_NAME" -e"insert into login_worldservers set note='', description='', name='$WORLD_NAME', account='$WORLD_ACCOUNT_NAME',password=sha2('$WORLD_ACCOUNT_PASSWORD',512);"};
	
	qx{rm "$EQ2WORLD_DB_FILE"};
	qx{rm "$EQ2WORLD_DB_SQL"};
	qx{wget "$EQ2WORLD_DB_PKG"};
	qx{tar -xzvf $EQ2WORLD_DB_FILE};
	qx{mysql -u"$MYSQL_USER" -hmysql -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" < "$EQ2WORLD_DB_SQL"};
	
	qx{mysql -u"$MYSQL_USER" -hmysql -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e"insert into web_users set username='$EQ2WORLD_WEB_ADMIN',passwd=sha2('$EQ2WORLD_WEB_PASSWORD',512);"};
	qx{echo "0" > first_install}
}

qx{rm "/eq2emu/server_loading"};

print "# Server Initial Load Up Complete... visit https://$IP_ADDRESS:$WEB_SERVER_PORT and use login credentials user: admin password: $EQ2DAWN_ADMIN_PASSWORD to establish when login and world server are online.\n";
