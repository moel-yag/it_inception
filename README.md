# inception

inception is a containerized hosting platform that runs multiple web services using Docker and Docker Compose.  
It is designed to provide a reproducible local/server environment where each service is isolated in its own container while still being able to communicate through an internal network.

> Repository: `moel-yag/inception`  
> Description: *host many services by using containers*

## 📚 Documentation & Deep Dives

### 1. Introduction
- [Project Overview](https://moel-yag.github.io/inception/index.html)
- [The Development Journey](https://moel-yag.github.io/inception/the-journey.html)

### 2. Core Docker Concepts
- [Docker Foundations](https://moel-yag.github.io/inception/foundations.html)
- [Kernel Isolation: How Containers Actually Work](https://moel-yag.github.io/inception/kernel-isolation.html)

### 3. Infrastructure Design
- [System Architecture](https://moel-yag.github.io/inception/architecture.html)
- [Network Virtualization & DNS](https://moel-yag.github.io/inception/networking.html)
- [Orchestration with Docker Compose](https://moel-yag.github.io/inception/orchestration.html)

### 4. Operations
- [Security & Best Practices](https://moel-yag.github.io/inception/best-practices.html)


## Overview
inception packages a complete multi-service stack into containers so that setup is simple and consistent across machines.

Main goals:
- Run multiple services in isolation.
- Keep the environment reproducible.
- Persist critical data with Docker volumes.
- Use a single command entry point for day-to-day operations.

## Architecture
At a high level, inception relies on:
- **Dockerfiles** to define service images.
- **Docker Compose** to orchestrate all services.
- **Docker Network(s)** for secure inter-service communication.
- **Volumes** for persistent state.
- **Shell scripts + Makefile** for automation.

Each service is built and started as a separate container, reducing coupling and making maintenance easier.

## How It Works
1. **Build phase**: Docker Compose reads service definitions and builds images (or pulls base images).
2. **Create phase**: Containers are created with mapped ports, environment variables, and attached volumes.
3. **Network phase**: Services join shared network(s), enabling internal communication by service name.
4. **Runtime phase**: Services start in dependency order managed by Compose.
5. **Persistence phase**: Important data is written to volumes so it survives container recreation.

This design makes it easy to tear down and bring up the full stack without losing required persistent data.

## Project Structure
> Exact paths may evolve; use this as a conceptual map.

- `docker-compose.yml` (or compose file): service orchestration.
- `Dockerfile` files: image build definitions.
- `Makefile`: common lifecycle commands.
- `*.sh`: setup/runtime helper scripts.
- Web assets (`HTML`, `CSS`, `JavaScript`) for service frontends/UI.

## Prerequisites
Install these on your machine:
- Docker Engine (latest stable)
- Docker Compose plugin (`docker compose`)
- GNU Make
- A Unix-like shell (bash/zsh)

Optional but recommended:
- `curl` for testing endpoints
- `jq` for JSON CLI parsing

## Quick Start
```bash
# 1) Clone
git clone https://github.com/moel-yag/inception.git
cd inception

# 2) Build and start all services
make

# 3) Verify running containers
docker ps 
```

## Make Command
```bash
# Build and run all services
make

# Stop and remove running stack
make down

# Rebuild everything from scratch and restart
make re

# Full cleanup (containers/images/other artifacts according to Makefile)
make fclean
```
## Operation Guids
```bash
# Show logs (all services)
docker compose logs -f

# Show logs for a specific service
docker compose logs -f <service_name>

# Restart one service
docker compose restart <service_name>

# Rebuild one service
docker compose build <service_name>

docker compose up -d <service_name>
```