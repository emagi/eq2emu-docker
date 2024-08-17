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
3. Use command prompt to open up the eq2emu-docker directory with docker-compose.yaml
4. Issue 'docker compose up'
5. A number of images will download to make the full server, this can take some time depending on your connection.
6. After about 1-2 minutes, eq2emu-server should appear on the prompt, briefly after you should be able to access https://127.0.0.1:2424/ for the admin interface, enter the EQ2DAWN_ADMIN_PASSWORD supplied in the .env file.
6. Use your compatible EverQuest 2 client to login by updating eq2_default.ini to us cl_ls_address 127.0.0.1