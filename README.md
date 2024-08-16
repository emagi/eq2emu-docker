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
2. Use command prompt to open up the eq2emu-docker directory with docker-compose.yaml
3. Issue 'docker compose up'
4. After about 1-2 minutes, you should be able to access https://127.0.0.1:2424/ for the admin interface, enter the EQ2DAWN_ADMIN_PASSWORD supplied in the .env file.
5. Use your compatible EverQuest 2 client to login by updating eq2_default.ini to us cl_ls_address 127.0.0.1