<br />
<div align="center">
  <h3 align="center">EQ2EMu Docker Edition</h3>

  <p align="center">
    Make sure to install Docker Desktop to get started, other Operating Systems be sure to install the Docker Engine and Docker Compose.
    <br />
    <a href="https://docs.docker.com/desktop/install/windows-install/"><strong>Docker Desktop Windows Install</strong></a>
    <a href="https://docs.docker.com/engine/install/">Other Operating Systems</a>
  </p>
</div>

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/emagi/eq2emu-docker.git
   ```
2. Use the .env.example file in the base directory to create a .env file and update all _PASSWORD fields with <template> with a password surrounded by quotes, eg. "custompassword"
	- Windows Users can use eq2emu.bat to be prompted for password fields and start, stop, down(remove) the eq2emu-docker services.  Skip step 3 and 4 if using eq2emu.bat to start.
3. Use command prompt to open up the eq2emu-docker directory with docker-compose.yaml
4. Issue 'docker compose up'
5. A number of images will download to make the full server, this can take some time depending on your connection.
6. After about 1-2 minutes, eq2emu-server should appear on the prompt, briefly after you should be able to access https://127.0.0.1:2424/ for the admin interface, enter the EQ2DAWN_ADMIN_PASSWORD supplied in the .env file.
7. Use your compatible EverQuest 2 client to login by updating eq2_default.ini to us cl_ls_address 127.0.0.1

## Additional Notes
http://127.0.0.1/eq2db will allow access to the EQ2EMu DB Editor, default user is 'admin' with the password EQ2EDITOR_ADMIN_PASSWORD set in the .env file.

If you do not wish to override existing database installations, you need to create an install directory in eq2emu-docker:
- File: first_install - skips login and world database creation in containers/eq2emu-server/entrypoint.pl
- File: dawn_install - skips dawn and login/world key/certificate creation for web polling/access.  Skips creating dawn database.
- File: firstrun_dbeditor - skips eq2db editor database creation and .env file configuration.

These files will auto-create after running the specified tasks, should the files not exist.