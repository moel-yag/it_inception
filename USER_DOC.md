# Inception User Guide

This guide is for users/operators who want to run and interact with Inception services.

### 1) What You Can Do as a User

With Inception, you can:

    Start all project services in one command.
    Stop and restart services safely.
    Monitor logs.
    Access hosted web interfaces/APIs through exposed ports.

### 2) Prerequisites

Before running Inception:

    Install Docker
    Install Docker Compose plugin
    Install Make

Check installation: docker --version docker compose version make --version
### 3) Run the Project

From repository root: make

This builds images (if needed) and starts the full stack.
### 4) Access Services

After startup:

    Run docker ps to list running containers.
    Identify published ports.
    Open your browser or API client using https://moel-yag.42.fr.

### 5) Common User Commands

    Start/build stack: make

    Stop stack: make down

    Rebuild from scratch: make re

    Full cleanup: make fclean

### 6) View Logs

    All services: docker compose -f ./srcs/docker-compose.yml logs -f

    Single service: docker compose -f ./srcs/docker-compose.yml logs -f <service_name>

### 7) Health Checks

Basic checks:

    Containers are running: docker ps
    No restart loops: docker ps --format '{{.Names}} {{.Status}}'
    Endpoints return responses (curl or browser)

```bash
curl -k -I https://moel-yag.42.fr
```
### 8) Data & Persistence

Inception uses Docker volumes for persistent data. This means:

    Restarting containers usually keeps data.
    Full cleanup commands may remove data depending on implementation.

`make re` and `make fclean` both delete the database and website data in the supplied Makefile. Back up before using either.
### 9) Troubleshooting

If services are not reachable:

    Confirm containers are up (docker ps).
    Check logs (docker compose -f ./srcs/docker-compose.yml logs -f).
    Verify port conflicts.
    Read the logs before rebuilding; make re deletes existing data.

If Docker permissions fail (Linux):

    Ensure your user belongs to the docker group.

### 10) Safe Usage Tips

    Avoid editing container internals directly.
    Prefer changing configuration/files in the repo and rebuilding.
    Keep local environment clean to avoid stale artifacts.

### Project access

Website: `https://moel-yag.42.fr`. Administration: `https://moel-yag.42.fr/wp-admin/`.
Map the domain to the machine running the project in your browser machine's hosts
file. The local self-signed certificate produces a browser warning. Usernames
and domain settings are in `srcs/.env`; passwords are in the local `secrets/`
files. Keep those password files out of Git.
