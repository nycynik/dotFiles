# Docker Testing Environment for dotFiles

This directory contains Docker configuration to test the dotFiles setup scripts in an isolated environment.

## Available Containers

1. **ubuntu-test**: An interactive environment where you can manually test the scripts
2. **automated-test**: A container that creates the basic directory structure for testing

## How to Use

### Interactive Testing

This is the recommended way to test the setup scripts. Run the interactive container:

```bash
# From the docker directory
docker compose up ubuntu-test

# Or to rebuild the image first
docker compose up --build ubuntu-test
```

Once inside the container, you can run:
```bash
cd /home/testuser/dotfiles
./setup.sh
```

### Automated Testing

The automated test container creates the basic directory structure without running the full interactive setup script:

```bash
# From the docker directory
docker compose up automated-test

# Or to rebuild the image first
docker compose up --build automated-test
```

This will:
1. Create a container
2. Run the test-setup.sh script, which:
   - Creates basic directories and files needed by the setup script
   - Creates symbolic links
   - Keeps the container running so you can inspect the results

### Inspecting and Testing Setup

After running either container, you can connect to it to inspect the environment or manually run setup commands:

```bash
docker exec -it automated-test /bin/bash
# OR
docker exec -it ubuntu-test /bin/bash
```

## Testing a Full Installation

Once you're connected to the container, you can try running the full setup script yourself:

```bash
cd /home/testuser/dotfiles
./setup.sh
```

## Troubleshooting

If you encounter issues:

1. Check that all scripts have execute permissions:
   ```bash
   chmod +x setup.sh setupscripts/*.sh
   ```

2. Ensure the volume mapping is correct in docker-compose.yml:
   ```yaml
   volumes:
     - ./..:/home/testuser/dotfiles
   ```

3. View logs:
   ```bash
   docker logs automated-test
   ```