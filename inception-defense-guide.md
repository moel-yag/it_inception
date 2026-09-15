# Inception: understand it, explain it, demonstrate it

Prepared for **moel-yag**, mandatory part only, using your subject version 5.3,
the 10-page EvalHub correction and the 6-page correction PDF. The two copies are
not identical; prepare for the fuller checklist, and follow the actual Intra
scale and subject used at your evaluation.

This is a learning guide, not a claim that your current repository passes. The
examples use the service names `nginx`, `wordpress`, and `mariadb` from the work
we examined. Run commands in the Linux VM, from the directory containing your
Makefile and `srcs/`. No bonus services are needed.

## How to study this guide

For each topic: **read the explanation, close it, explain it aloud, then show it
with a command or browser action**. Finally answer its prediction question.
An answer you understand can survive a follow-up question; a memorized sentence
usually cannot. Use the suggested answers as examples, not a speech to recite.

Do sections 1-7 first. Then practice the demonstrations in section 10 and the
configuration change in section 11. Finish with the questions in section 13.

## 1. Explain your whole project in one minute

> My project runs a WordPress website using three containers inside a Linux VM.
> NGINX receives HTTPS requests on port 443. It serves static files and sends PHP
> requests to PHP-FPM in the WordPress container. WordPress reads and writes its
> database through MariaDB. The containers communicate through a Docker network.
> Two volumes preserve the database and website files. A Makefile uses Compose
> to build and start the services.

```text
Browser
   | HTTPS, host port 443
   v
NGINX ---- FastCGI, port 9000 ----> PHP-FPM executes WordPress
   |                                      |
   | reads static files                   | SQL, port 3306
   |                                      v
   +---- shared WordPress volume       MariaDB
              ^                           |
              | WordPress writes          | stores database files
              +-----------------      database volume
```

Think of NGINX as the front desk, PHP-FPM as the workers, and MariaDB as the
organized records. This analogy explains their jobs; the actual connections
use HTTPS, FastCGI, and SQL respectively.

### Follow one page request

1. The browser resolves `moel-yag.42.fr` to an IP address.
2. It connects to port 443 and negotiates TLS with NGINX.
3. NGINX chooses the server block and requested path.
4. A static file can be served directly. A PHP request goes to PHP-FPM.
5. WordPress PHP code may query MariaDB for posts, settings, and users.
6. PHP produces the response; NGINX sends it to the browser over HTTPS.

**Prediction:** If MariaDB stops, can NGINX still run? Yes. A static file may
still load, but WordPress requests needing the database fail.

## 2. Docker, images, containers, Compose and the VM

### The five objects you must distinguish

| Object | Plain meaning | In this project |
| --- | --- | --- |
| Dockerfile | Build instructions | Install NGINX and copy its configuration |
| Image | Packaged filesystem and runtime metadata | Your built NGINX image |
| Container | An instance created from an image, with runtime state | The running NGINX process and its environment |
| Compose file | Description of connected services | Builds, ports, volumes, network, variables |
| Makefile | Named commands for the project | `make` invokes Compose |

An image is not a running server. One image can create multiple containers.
An image is immutable; a container adds its own writable layer. Images have
reusable filesystem layers, and builds can reuse cached results. Rebuilding
creates a new image; it does not rewrite every already-running container.
[Docker: images](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-an-image/).

Docker's CLI sends requests to the Docker daemon, which manages containers,
images, networks and volumes. `/var/run/docker.sock` is a local Unix socket used
for that communication; it is not your website's network port. The permission
error you saw earlier was about accessing this socket.

### Why use a VM and containers together?

A VM has its own guest kernel and operating system. Linux containers share the
Docker host's kernel while isolating processes and resources. In your project,
the host for those containers is the Linux VM. Containers usually need less
overhead than separate VMs per service, but they do not replace the subject's
VM requirement or provide an identical isolation boundary.

Namespaces separate views such as processes and networking; cgroups account for
and limit resources. Know those names and their jobs; a kernel-internals lecture
is not necessary for this correction.
[Docker: containers and VMs](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-a-container/).

### The correction's tricky Compose question

**“What is the difference between an image with Compose and without Compose?”**

The image itself does not become a different kind of image. Compose describes
how to build/run services together. Without Compose, you could use Docker
commands to create the same network, volumes and containers individually.

### Demonstrate

```bash
docker image ls
docker compose -f srcs/docker-compose.yml ps -a
```

Explain the difference between IMAGE, SERVICE, STATUS and PORTS. `Up` means a
container's main process is running; it does not prove WordPress installed.
Your failed download followed by an `Up` PHP-FPM container demonstrated that.

**Prediction:** If you edit a Dockerfile then only restart a container, does it
use your edit? No. Build the changed image and recreate the container.

## 3. Read every Dockerfile and the Compose file

### Dockerfile vocabulary

| Instruction | Meaning |
| --- | --- |
| `FROM` | Choose the base image |
| `RUN` | Execute a build-time command |
| `COPY` | Copy from the build context into the image |
| `WORKDIR` | Set the working directory |
| `ENV` | Set an image environment default |
| `ARG` | Declare a build-time variable; not a safe password store |
| `EXPOSE` | Document a container port; it does not publish it |
| `ENTRYPOINT` | Define the main startup executable |
| `CMD` | Provide defaults, often arguments to an entrypoint |

`RUN apt-get update` refreshes package metadata. `apt-get install` installs the
service. Removing APT lists in the same `RUN` reduces leftover build-layer data.
The build context limits which local files `COPY` can use. Runtime database
initialization belongs in startup logic because runtime volumes and secrets
are not simply the image's build-time filesystem.
[Dockerfile reference](https://docs.docker.com/reference/dockerfile/).

### Read this small Compose example

```yaml
nginx:
  build: ./requirements/nginx
  image: nginx:inception
  ports:
    - "443:443"
  volumes:
    - wp_data:/var/www/html/wordpress
  networks:
    - inception_net
  restart: always
```

Explain it aloud: “Build from this directory, name the result `nginx:inception`,
publish host 443 to container 443, attach the website volume, join the network,
and apply a restart policy.” This is an explanatory excerpt, not a replacement
for your full file.

Know the difference between `build` (how to create an image), `image` (its name),
the service key (the Compose service), and `container_name` (an optional explicit
container name). A tag such as `:inception` is separate from the image name.
Omitting a tag implies `latest`, which your subject prohibits.

### Project-specific choices

- Three services, three Dockerfiles; no prebuilt WordPress/NGINX/MariaDB images.
- The subject allows Alpine/Debian base images. It does not prohibit downloading
  Debian packages or WordPress software.
- Penultimate stable means the release before the current stable major release.
  As checked during this review, Debian 13 is stable and Debian 12 Bookworm is
  oldstable. Recheck if the evaluation date changes substantially.
- `srcs/` keeps configuration together; the root Makefile provides one starting
  command. Required documentation is also at repository root.

**Prediction:** If you change a file that a Dockerfile copies, what must happen?
Rebuild the affected image and recreate the service to use the new copy.

## 4. Networking, DNS and ports

### There are two different name-resolution problems

**Browser to website:** the browser's machine must resolve `moel-yag.42.fr` to
the Docker host/VM. A hosts-file entry makes a local mapping; it does not register
a public domain. Editing Linux's hosts file does not automatically edit Windows'.

**Container to container:** on the Compose network, service names resolve through
Docker's DNS. NGINX uses `wordpress:9000`; WordPress uses `mariadb:3306`.
Use names instead of fixed container IPs, which may change on recreation.

Inside a container, `localhost` means that container. Therefore, WordPress
connecting to `localhost:3306` does not reach the separate MariaDB container.
Host networking removes the separate network namespace and is forbidden here.
The project's bridge network is not an automatic guarantee of complete security.
[Compose networking](https://docs.docker.com/compose/how-tos/networking/).

### Port numbers are doors; protocols are the language through them

| Connection | Protocol | Port in this project |
| --- | --- | --- |
| Browser to NGINX | HTTPS | 443 |
| NGINX to PHP-FPM | FastCGI | 9000 |
| WordPress to MariaDB | MySQL/MariaDB protocol carrying SQL | 3306 |

In `"443:443"`, the left side is the host port and the right side is the
container port. Only NGINX should publish a host port. `3306/tcp` in `docker ps`
is not the same as `0.0.0.0:3306->3306/tcp`; only the latter shows publication.
`EXPOSE` alone does not create that mapping. Publishing without a host-IP
restriction normally binds on the host's interfaces.
[Docker port publishing](https://docs.docker.com/engine/network/port-publishing/).

### Demonstrate

```bash
docker network ls
docker compose -f srcs/docker-compose.yml exec wordpress getent hosts mariadb
docker compose -f srcs/docker-compose.yml exec nginx getent hosts wordpress
```

Inspect the actual network name shown by `docker network ls`; Compose normally
prefixes resource names with its project name.

**Prediction:** If the browser says “server not found,” is changing MariaDB's
password the first fix? No. Check browser-side hostname resolution first.

## 5. NGINX, HTTPS, WordPress and PHP-FPM

### NGINX configuration, line by line

| Setting | Explain it simply |
| --- | --- |
| `listen 443 ssl` | Accept TLS connections on container port 443 |
| `server_name moel-yag.42.fr` | Match the requested hostname; does not create DNS |
| `root /var/www/html/wordpress` | Locate website files |
| `index index.php ...` | Choose a directory's index file |
| `location /` | Rules for normal paths |
| `try_files` | Try files/paths, then the configured fallback |
| `location ~ \.php$` | Match PHP paths |
| `fastcgi_pass wordpress:9000` | Send PHP work to PHP-FPM |
| `SCRIPT_FILENAME` | Tell PHP-FPM which PHP file to execute |

NGINX does not execute PHP. FastCGI communicates between NGINX and the PHP
runtime; it is not an ordinary browser HTTP endpoint. Both containers need a
consistent view of the PHP file paths.
[NGINX beginner guide](https://nginx.org/en/docs/beginners_guide.html).

### What PHP-FPM does

PHP-FPM manages worker processes that execute PHP requests. WordPress is the
application written in PHP; FPM is the process manager running that code.

Your pool configuration sets `user/group = www-data`, `listen = 9000`, and
`pm = dynamic`. `pm.max_children` caps workers, `pm.start_servers` sets the initial
worker count, and the spare-server settings control idle workers. A pool can
serve several requests concurrently. `listen.owner` and `listen.group` apply
to Unix sockets; they do not restrict a TCP `listen = 9000` to one Linux user.
[PHP-FPM manual](https://www.php.net/manual/en/install.fpm.php).

### What TLS provides

TLS protects traffic against reading and tampering and can authenticate the
server. The certificate identifies the server and carries its public key;
the private key stays on the server. A handshake establishes keys for encrypted
traffic. A self-signed certificate can encrypt traffic but is not automatically
trusted by a browser. Your evaluation permits that warning.

The protocol version is TLS 1.2/1.3; it is not literally the certificate's version.
`ssl_protocols TLSv1.2 TLSv1.3;` restricts negotiation. `curl -k` skips certificate
verification, not encryption. Keep the required baseline HTTPS-only even though
the reviewer may request a temporary port modification.
[NGINX HTTPS](https://nginx.org/en/docs/http/configuring_https_servers.html).

### Your WordPress startup commands

| Command | Job |
| --- | --- |
| `wp core download` | Download WordPress files |
| `wp config create` | Write database settings to `wp-config.php` |
| `wp core install` | Create WordPress tables/options and the first admin |
| `wp user create` | Create the second WordPress account |
| `wp rewrite structure` | Configure permalink structure |
| `wp rewrite flush` | Refresh WordPress rewrite rules |
| `php-fpm8.2 -F` | Run PHP-FPM in the foreground |

`--allow-root` permits WP-CLI to run as Linux root; it does not make every
WordPress user an administrator. Having `wp-config.php` does not prove the
database installation finished. `wp core is-installed` checks installation.

**Prediction:** Why did you get 403 although the containers were up? In your
observed incident the WordPress download failed, leaving no usable index files,
while the script still started FPM. A 403 can have other causes too; logs identify
the actual one.

## 6. MariaDB, accounts, SQL and secrets

### Four accounts that are easy to confuse

| Account | Scope |
| --- | --- |
| Linux root | Operating-system/container permissions |
| MariaDB root | Database administration |
| SQL service user | WordPress's access to its database |
| WordPress admin/author | Permissions inside the website |

The website administrator is not the database root account. WordPress should
use a restricted SQL account for its database, not MariaDB root. A MariaDB
account includes both a username and host, so `user@localhost` and `user@%`
are different account definitions. `%` permits matching remote hosts; network
reachability and granted privileges still matter.

Know what your script's SQL means: `CREATE DATABASE` creates storage for tables;
`CREATE USER` creates an account; `GRANT` assigns permissions; `ALTER USER`
changes account configuration/password. `FLUSH PRIVILEGES` reloads privilege
tables; standard account-management statements normally apply immediately.

### Demonstrate database access without exposing a password

```bash
docker compose -f srcs/docker-compose.yml exec mariadb mariadb -u root -p
```

Type the root password at the hidden prompt. Then run:

```sql
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT ID, post_title FROM wp_posts LIMIT 5;
exit;
```

Replace `wordpress` with your actual database name and `wp_` with the actual
table prefix if different. Explain why actual tables and rows prove more than
an empty database directory. `-u` selects the user; `-p` without a value requests
the password interactively.
[MariaDB client](https://mariadb.com/docs/server/clients-and-utilities/mariadb-client/mariadb-command-line-client).

### Environment variables versus secrets

Use variables for settings such as the domain and database name. With Compose,
`.env` can supply `${VARIABLE}` substitution in YAML, while a service's
`env_file: .env` explicitly supplies variables inside that container. These are
related but different mechanisms. Existing shell variables can override values
used for interpolation, which matters for `${HOME}`.
[Compose interpolation](https://docs.docker.com/compose/how-tos/environment-variables/variable-interpolation/).

Compose secrets give selected containers files such as `/run/secrets/db_password`.
Your shell script reads the file. Local file-based secrets are not magically
encrypted and are not safe to commit merely because the directory is named
`secrets`. `.gitignore` prevents accidental tracking of untracked files; it
does not untrack existing files or erase history. Used passwords that were
published need rotation. Do not include actual passwords in an explanation,
screenshot or printed environment dump.
[Compose secrets](https://docs.docker.com/compose/how-tos/use-secrets/).

**Prediction:** If you edit a password file, does the existing database account
automatically change? No. That depends on explicit account-update logic. Your
original script skips initialization once the database directory exists.

## 7. Volumes, persistence, processes and startup

### Where does your data live?

| Data | Location inside its container |
| --- | --- |
| WordPress code, plugins, uploads and config | `/var/www/html/wordpress` |
| MariaDB database files | `/var/lib/mysql` |

A named volume is managed by Docker and survives removal of the container.
A bind mount maps a chosen host path. The container's own writable layer
survives stopping/restarting that same container but is lost when it is removed.
Do not say “all data disappears whenever a container restarts.”

WordPress and NGINX share the website volume; MariaDB uses the other volume.
Posts/users/settings are in the database, while uploaded image bytes are files.
A volume is persistence, not a backup. Inspect both the mount type/options and
the physical location; names alone do not explain storage.
[Docker volumes](https://docs.docker.com/engine/storage/volumes/).

Your subject requires named volumes under `/home/moel-yag/data` and forbids bind
mounts. A declaration with `o: bind` is bind-backed even if the container mount
is called a named volume. The correction sheets' path check does not remove the
subject's rule. Do not claim the old configuration is fully compliant just
because an inspect output contains the required path.

### The process that keeps a container alive

PID means process identifier. PID 1 is the first process in the container's
process namespace; its lifetime determines whether the container remains
running. It also has special signal and child-process responsibilities.

`exec nginx -g 'daemon off;'` replaces the startup shell with foreground NGINX.
`exec php-fpm8.2 -F` does the same for FPM. Shell-form startup can add a shell
between Docker and the service and complicate signal forwarding. A wrapper such
as `mysqld_safe` is not the same executable as the actual database server.
[Docker: entrypoints and signals](https://docs.docker.com/reference/build-checks/json-args-recommended/).

`docker compose up -d` detaches your terminal from Docker's output. It does
**not** mean the server inside the container should daemonize or use `&`.
Running `tail -f` to keep an otherwise finished container alive is prohibited.
Both correction PDFs also literally prohibit background programs in entrypoint
scripts: account for that when fixing the original `mysqld_safe &` bootstrap.

### Running is not ready

Basic `depends_on` orders startup but does not prove MariaDB can accept queries.
A healthcheck plus `condition: service_healthy` can gate initial startup on
readiness. A bounded retry can handle a temporary delay; a fixed sleep merely
guesses how long startup takes. Check command failures and do not print success
after a failed installation. Idempotent startup means repeating it does not
damage existing data or duplicate users.
[Compose startup order](https://docs.docker.com/compose/how-tos/startup-order/).

`restart: always` applies when a container exits, with documented exceptions
for manual stops. It does not automatically restart an unhealthy-but-running
service. Docker must itself start after a VM reboot. Neither restart policies
nor healthchecks fix invalid configuration.
[Docker restart policies](https://docs.docker.com/engine/containers/start-containers-automatically/).

### Shell syntax you must be able to explain

| Syntax | Meaning in a startup script |
| --- | --- |
| `#!/bin/bash` | Select Bash as interpreter |
| `$(command)` | Capture command output |
| `"$VARIABLE"` | Expand while preserving it as one argument |
| `[ ! -f file ]` | Test that a regular file does not exist |
| `[ ! -d directory ]` | Test that a directory does not exist |
| `&&` | Run the next command only if the first succeeds |
| `&` | Start a command in the background |
| `>/dev/null 2>&1` | Discard standard output and standard error |
| `<<EOF` | Feed following text as standard input until the delimiter |
| `chmod +x` | Add execute permission |
| `chown` | Change file ownership |
| `set -e` | Stop on many unhandled command failures; exceptions exist |
| `set -u` | Treat unset variable expansion as an error |
| `set -o pipefail` | Preserve failure from a command in a pipeline |

Adding `set -e` alone does not repair partial setup or make a retry idempotent.
Read each branch and ask what is left on disk if its next command fails.

## 8. Mandatory rules to know without searching

- Work in a VM; configuration in root `srcs/`; root Makefile starts the stack.
- Three separate containers: NGINX, WordPress with PHP-FPM, MariaDB.
- Own Dockerfiles and builds; allowed penultimate Alpine/Debian base.
- Image names match services; do not use `latest`.
- Only NGINX exposes the infrastructure through 443; TLS 1.2/1.3.
- No NGINX in the WordPress or MariaDB image.
- Docker network; no host network, `links`, or `--link`.
- No keepalive hacks or infinite entrypoint loops; heed background-process wording.
- Two persistent named volumes under `/home/moel-yag/data`; no bind mounts.
- `moel-yag.42.fr` resolves to the local evaluation host/VM as appropriate.
- Two WordPress users including an administrator whose name contains no `admin`.
- Runtime variables and local credentials; no passwords in Dockerfiles or Git.
- Restart after crashes; demonstrate data surviving a VM reboot.
- Root README: required opening, Description, Instructions, Resources/AI usage,
  project choices, and the four comparisons taught above; English.
- Root USER_DOC and DEV_DOC: real usage, setup, credentials, commands and storage.
- Be able to explain your submitted work and make a requested small change.

The sheets explicitly check authorship and understanding. Learning these concepts
does not replace resolving implementation gaps or accurately describing where
your starting code came from. Bonus work is unnecessary for mandatory-only scope.

## 9. Command vocabulary and what each command proves

| Command | What it does or proves |
| --- | --- |
| `docker compose -f srcs/docker-compose.yml config --quiet` | Validates Compose configuration; does not prove runtime health |
| `docker compose -f srcs/docker-compose.yml up -d --build` | Builds and creates/starts the configured services |
| `docker compose -f srcs/docker-compose.yml ps -a` | Shows running and stopped project containers |
| `docker compose -f srcs/docker-compose.yml logs --tail=50 wordpress` | Shows recent container stdout/stderr |
| `docker compose -f srcs/docker-compose.yml exec wordpress sh` | Opens a shell in an existing running service |
| `docker compose -f srcs/docker-compose.yml stop` | Stops containers while keeping their state and volumes |
| `docker compose -f srcs/docker-compose.yml down` | Removes project containers/network; normally retains named volumes |
| `docker compose -f srcs/docker-compose.yml restart wordpress` | Restarts the existing service; does not rebuild its image |
| `docker volume ls` | Lists volumes; does not prove their contents or paths |
| `docker volume inspect VOLUME_NAME` | Shows the chosen volume's driver, options and mountpoint |
| `docker network inspect NETWORK_NAME` | Shows network configuration and connected containers |

Replace uppercase names with actual output values. Do not assume Compose's
project prefix. `docker compose logs -f` follows logs; Ctrl+C exits the viewer.
Some services write log files instead of stdout, so quiet Docker logs are not
proof that there were no errors.

Read your own Makefile: in the original version `make re` invokes `fclean` and
deletes data. It is not a safe substitute for restarting during a persistence
test. The correction's global Docker cleanup is destructive and belongs only
in an isolated evaluation environment, not routine troubleshooting.

## 10. Practice the actual correction, in order

### A. Preparation and fresh build

Show the repository layout and the three documentation files. Explain how local
`.env` and secret files are created after cloning. Show that credentials are
not tracked. A fresh clone cannot rely on uncommitted files from your old folder.
Run the Makefile on the prepared evaluation VM and inspect all containers.

### B. HTTPS and HTTP

```bash
curl -k -I https://moel-yag.42.fr/
curl -I --max-time 5 http://moel-yag.42.fr/
```

HTTPS should reach the configured site. HTTP should not connect to this site's
port 80. A redirect from HTTP to HTTPS would still mean HTTP is accessible.
Then open the HTTPS site in a real browser; a curl-only success is insufficient.

Demonstrate exact supported TLS versions:

```bash
curl -k -I --tlsv1.2 --tls-max 1.2 https://moel-yag.42.fr/
curl -k -I --tlsv1.3 --tls-max 1.3 https://moel-yag.42.fr/
docker compose -f srcs/docker-compose.yml exec nginx nginx -T
```

Inspect the active config's protocol restrictions. A legacy-TLS test can fail
because the client disables old TLS; that alone does not prove server rejection.

### C. WordPress users and editing

```bash
docker compose -f srcs/docker-compose.yml exec wordpress wp --allow-root user list --fields=ID,user_login,roles
```

Explain the administrator and second user's roles. Log in as the second user
and add a comment to a post that allows comments. If moderation is enabled,
approve it as administrator and show it. Log in at `/wp-admin/`, edit a page,
and show the visible change on the website. The site must already be installed,
not display the installation wizard.
[WP-CLI user listing](https://developer.wordpress.org/cli/commands/user/list/).

### D. Database and volumes

Use the database login demonstration in section 6. Show actual tables/rows.
List volumes and inspect both real names. Explain how each host-side path maps
to the corresponding container destination; show `/home/moel-yag/data/`.

### E. Persistence

Create a clearly recognizable comment/page edit, optionally upload an image,
then reboot the evaluation VM normally. After it comes back, launch Compose
again and confirm those exact changes remain. Do not delete volumes or use the
original `make re` between the two observations. Explain which volume stores
each piece of evidence.

### F. Process/restart explanation

```bash
docker compose -f srcs/docker-compose.yml exec nginx cat /proc/1/comm
docker compose -f srcs/docker-compose.yml exec wordpress cat /proc/1/comm
docker compose -f srcs/docker-compose.yml exec mariadb cat /proc/1/comm
```

Explain actual output rather than assuming it. Distinguish a deliberate Compose
stop from an unexpected main-process exit when demonstrating restart behavior.
Do not deliberately crash MariaDB during an unbacked-up write operation.

## 11. Be ready for a live configuration change

The EvalHub sheet requires a small service-configuration change followed by
rebuild/restart and a working demonstration. Do not alter your baseline until
practicing deliberately or requested by the evaluator; restore it afterwards.

### Practice example: change PHP-FPM from 9000 to 9001

This avoids changing the mandatory external HTTPS port:

1. In the WordPress pool file, change `listen = 9000` to `listen = 9001`.
2. In NGINX configuration, change `fastcgi_pass wordpress:9000` to
   `fastcgi_pass wordpress:9001`.
3. Update the WordPress Dockerfile's `EXPOSE` for consistency. If your current
   version has healthchecks or other references to 9000, update those too.
4. Rebuild/recreate the affected services, keeping volumes:

   ```bash
   docker compose -f srcs/docker-compose.yml up -d --build wordpress nginx
   ```

5. Check logs and open a PHP page, such as `/wp-login.php`, then log in. A static
   image alone does not prove the new FastCGI connection works.
6. Restore 9000 everywhere and rebuild again when the practice is over.

**Explain why two main configs change:** one service listens, the other connects.
Changing only NGINX's destination creates a connection to a port with no listener.

If asked to change a published port, first distinguish host port from container
port. Changing `443:443` to `8443:443` changes the host-side entry only, while
changing NGINX's `listen` changes its actual internal listener. A host-port
change can also require updating the website URL to avoid redirects to 443.

## 12. Troubleshoot by locating the broken connection

| Symptom | First place to investigate |
| --- | --- |
| Browser: server not found | Browser machine's hosts/DNS resolution |
| Connection refused | Host port mapping, running NGINX, reachable VM address |
| Certificate warning | Self-signed trust and hostname; encryption may still work |
| 403 Forbidden | NGINX error log, index files and file permissions |
| 502 Bad Gateway | PHP-FPM running/listening, service DNS, matching ports |
| WordPress database error | SQL server readiness, hostname, credentials, DB name |
| WordPress installation screen | Installation/tables/config/volume mismatch |
| Container says Up but site fails | Main process lives; inspect application logs and files |
| Changes vanish after recreation | Wrong volume, changed project name, or deleted storage |

Your incident is a useful explanation: container DNS failed while downloading
WordPress, the script continued, NGINX returned 403, and a later restart succeeded
when DNS worked. After that, curl returned 200 but Firefox still could not resolve
the hostname. Those were two separate failures at different connections.

This isolates browser-side DNS when run on the machine hosting published 443:

```bash
curl -k -I --resolve moel-yag.42.fr:443:127.0.0.1 https://moel-yag.42.fr/
```

`--resolve` affects this curl request only. It does not repair Firefox's DNS.
If running curl outside the VM, use the actual reachable endpoint instead of
assuming `127.0.0.1` means the VM.

## 13. Self-test: answer without looking

Cover the right column. Say a short answer and explain your reasoning.

| Question | Essential answer |
| --- | --- |
| What executes PHP? | PHP-FPM workers, not NGINX |
| Does Compose create a special image format? | No; it manages service configuration and lifecycle |
| Why three containers? | Separate required services and their dependencies/lifecycles |
| What does the left 443 mean? | The published host port |
| Does EXPOSE open a host port? | No |
| Why does localhost fail as the DB hostname? | It points back to the WordPress container |
| What does server_name do? | Selects a virtual server; it does not register DNS |
| Why can a self-signed site still use HTTPS? | Encryption and browser trust are separate questions |
| Is a certificate itself “TLS 1.3”? | TLS version belongs to the negotiated connection |
| What is PID 1? | The first process in the container's process namespace |
| Why exec at the end of a script? | Replace the shell with the main service |
| Why not tail -f? | It keeps a container alive for the wrong process and is prohibited |
| Does depends_on mean the DB accepts SQL? | Not with basic startup ordering alone |
| Does restart: always fix an unhealthy live process? | No; restart policies concern process/container exits |
| Are a website admin and SQL root the same? | No; different systems and privileges |
| Does wp-config.php prove installation? | No; the database installation can still be missing |
| What persists after normal down? | Named volumes, unless explicitly removed |
| What survives a simple restart without volumes? | The same container's writable layer; not its removal |
| Where are post text and uploaded image bytes? | Post in SQL; uploaded file in the website volume |
| Does .gitignore erase an old password commit? | No |
| What if only the FastCGI client port changes? | NGINX connects to the wrong listener; likely 502 |
| Does restarting apply a Dockerfile edit? | No; rebuild and recreate |
| Why keep the same Compose project name? | It affects generated resource names, including volumes |
| What do you show after reboot? | The actual previously edited page/comment and functional DB/site |

## 14. A short rehearsal plan

**Session A, about 90 minutes:** draw the request path from memory; learn sections
2-7; open your three Dockerfiles and explain every instruction. Read each startup
script and predict what happens after each command fails. Revisit any answer you
cannot explain without the guide.

**Session B, about 90 minutes:** perform the correction demonstrations, practice
the internal-port change, restore the baseline, and answer the self-test aloud.
Build/download time and VM setup are additional, so allow time for real errors.

Before the defense, you should be able to do five things without copying an
answer: draw the architecture, explain the configs, show the required behavior,
diagnose a failed connection, and make a small requested change. A working page
and a good explanation are both necessary; neither replaces the other.
