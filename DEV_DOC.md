# Inception Developer Guide

This guide is for developers who want to extend, debug, or maintain Inception.
### 1) Development Goals

As a developer, you should be able to:

    Understand container/service boundaries.
    Modify service Dockerfiles and compose definitions.
    Add new services safely.
    Debug startup/runtime issues quickly.

### 2) Recommended Knowledge

    Docker & Docker Compose fundamentals
    Linux shell scripting
    Networking basics (ports, DNS, bridge networks)
    Basic frontend/web stack knowledge (HTML/CSS/JS)

### 3) Local Development Workflow

    Create a branch.
    Make focused changes.
    Rebuild relevant service(s).
    Test end-to-end.
    Submit PR with clear description.

Typical cycle:

    Start full stack: make

    After changing Dockerfile/compose: make (rebuild changed images)

    make re deletes database and website data; use only for an intentional reset.

    Inspect logs during testing: docker compose -f ./srcs/docker-compose.yml logs -f

### 4) How Components Interact

Inception uses Docker Compose as the orchestrator:

    Services are declared in compose.
    Each service maps to a build context/image.
    Services communicate over an internal network.
    Volumes store stateful data.

When adding dependencies between services:

    Prefer internal service-to-service communication by service name.
    Keep external ports minimal.

### 5) Adding a New Service

General checklist:

    Add Dockerfile/build context.
    Add service entry in compose file.
    Define environment variables.
    Configure volumes (if stateful).
    Expose only necessary ports.
    Validate with docker compose -f ./srcs/docker-compose.yml config.
    Rebuild and test.

### 6) Debugging Strategy

Use this order:

    docker compose -f ./srcs/docker-compose.yml config (syntax/merge validation)
    docker compose -f ./srcs/docker-compose.yml ps (status)
    docker compose -f ./srcs/docker-compose.yml logs -f <service> (runtime errors)
    docker exec -it <container> sh (inside-container checks)
    Rebuild with no cache if required: docker compose -f ./srcs/docker-compose.yml build --no-cache <service>

### 7) Coding & Config Practices

    Keep scripts idempotent where possible.
    Fail fast in shell scripts (set -euo pipefail when appropriate).
    Keep Docker layers efficient (cache-friendly ordering).
    Pin versions for deterministic builds when feasible.
    Document any new env variable in docs.

### 8) Branching & PR Best Practices

    Branch naming: feature/..., fix/..., chore/...
    Commit messages: concise + imperative (e.g., Add nginx healthcheck)
    PR should include:
        What changed
        Why it changed
        How to test
        Any migration/ops impact

### 9) Suggested Validation Checklist

Before merging:

    make succeeds on clean environment
    make re succeeds
    Services healthy and reachable
    No unintended port changes
    Docs updated (README/USER/DEVELOPER)

### 10) Maintenance Tips

    Periodically update base images.
    Remove unused images/volumes in dev environments.
    Review compose and scripts for security hardening.
    Keep documentation aligned with current behavior.
