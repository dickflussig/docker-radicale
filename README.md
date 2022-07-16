

# dickflussig/radicale

[Radicale](https://radicale.org) is a fantastic DAV server, providing CardDAV (contacts) and CalDAV (calendars, to-do lists) synchronisation. 


**Now even simpler to deploy in docker!**

- Works out of the box.
- Detailed instructions to set up a secure server with authentication, `SSL`.
- Easy collection locking for backup or version control.
- Sync your data without cloud services.

## Quick Start ##

Radicale is really easy to install and works out of the box.

```yaml
docker run --rm \
  --name=radicale \
  -p 5232:5232/tcp \
  dickflussig/radicale:latest
```

Start a Radicale instance, listening on port `5232/tcp`. Now open [http://localhost:5232](http://localhost:5232) in your browser.<br>
Login with any username and password.

## Detailed Setup ##

A more secure setup with authentication, `SSL` and exclusive collection locking.


The Radicale container expects two bind mounts, one for configs, the other for collection data.<br>
Create the following folder structure on the host system.

```
 /app/
    ├── conf
    └── storage
```


### Radicale Config File ###

Create the below `radicale.conf` and save it to the `conf` folder.

*Configuration categories and options are described below.*


```yaml
[server]
# Bind all addresses
hosts = 0.0.0.0:5232, [::]:5232
# A comma separated list of addresses that the server will bind to.
# Default: localhost:5232

max_connections = 8
# The maximum number of parallel connections. Set to 0 to disable the limit.
# Default: 8

max_content_length = 100000000
# The maximum size of the request body. (bytes)
# Default: 100000000

timeout = 30
# Socket timeout. (seconds)
# Default: 30

ssl = True
# Enable transport layer encryption.
# Default: False

certificate = conf/radicale.cert.pem
# Path of the SSL certifcate.
# Default: /etc/ssl/radicale.cert.pem

key = conf/radicale.key.pem
# Path to the private key for SSL. Only effective if ssl is enabled.
# Default: /etc/ssl/radicale.key.pem

[auth]
type = htpasswd
# The method to verify usernames and passwords.
# Available backends: none, htpasswd, remote_user, http_x_remote_user
# See https://radicale.org/v3.html#configuration
# Default: none

htpasswd_filename = conf/users
# Path to the htpasswd file.

htpasswd_encryption = bcrypt
# The encryption method that is used in the htpasswd file. Use the htpasswd or similar to generate this files.
# Available methods: See https://radicale.org/v3.html#configuration

# delay = 1
# Average delay after failed login attempts in seconds.
# Default: 1

# realm = Radicale - Password Required
# Message displayed in the client when a password is needed.
# Default: Radicale - Password Required

[storage]
type = multifilesystem
# The backend that is used to store data.
# Available backends: See https://radicale.org/v3.html#configuration
# Default: multifilesystem

filesystem_folder = storage
# Folder for storing local collections, created if not present.
# Default: /var/lib/radicale/collections

[web]
type = internal
# The backend that provides the web interface of Radicale.
# Available backends:
# none : Just shows the message "Radicale works!".
# internal : Allows creation and management of address books and calendars.
# Default: internal

[logging]
level = debug
# Set the logging level.
# Available levels: debug, info, warning, error, critical
# Default: warning

mask_passwords = True
# Don't include passwords in logs.
# Default: True
```


### SSL Encryption ###

A secure connection between Radicale and client can be enabled with `SSL`.

```yaml
ssl = True
# Enable transport layer encryption.
# Default: False

certificate = conf/radicale.cert.pem
# Path of the SSL certifcate.
# Default: /etc/ssl/radicale.cert.pem

key = conf/radicale.key.pem
# Path to the private key for SSL. Only effective if ssl is enabled.
# Default: /etc/ssl/radicale.key.pem
```

The following command will generate a self-signed `SSL` certificate. You will be asked to enter additional information about the certificate, the values don't matter, and you can keep the defaults. 

```bash
openssl req -nodes \
  -x509 \
  -newkey rsa:4096 \
  -keyout radicale.key.pem \
  -out radicale.cert.pem \
  -sha256 \
  -days 365
```


Place the `radicale.key.pem` and `radicale.cert.pem` files in the `conf` folder.

```
 /app/
    ├── conf
    │    ├── radicale.cert.pem
    │    ├── radicale.conf
    │    └── radicale.key.pem
    └── storage
```

Or use your own certificate. Make sure to update the `SSL` configuration category in `conf/radicale.conf` accordingly.


### Authentication ###

The [htpasswd](https://httpd.apache.org/docs/2.4/programs/htpasswd.html) utility is used to create and update the flat-files used to store usernames and password for basic authentication of `HTTP` users.

```bash
htpasswd -B -c users <username>
```

This will create a file called `users` for user `<username>`. This file also needs to be placed in the `conf` folder.

```
 /app/
    ├── conf
    │    ├── radicale.cert.pem
    │    ├── radicale.conf
    │    ├── radicale.key.pem
    │    └── users
    └── storage
```

```yaml
[auth]
type = htpasswd
# The method to verify usernames and passwords.
# Available backends: See https://radicale.org/v3.html#configuration
# Default: none

htpasswd_filename = conf/users
# Path to the htpasswd file.

htpasswd_encryption = bcrypt
# The encryption method that is used in the htpasswd file. 
# Use the htpasswd or similar to generate this files.
# Available methods: See https://radicale.org/v3.html#configuration

delay = 1
# Average delay after failed login attempts in seconds.
# Default: 1

realm = Radicale - Password Required
# Message displayed in the client when a password is needed.
# Default: Radicale - Password Required
```


### Storage ###

Collection data is stored in the `storage` folder and made accessible to the locale system via bind mount.


```yaml
[storage]
type = multifilesystem
# The backend that is used to store data.
# Available backends: See https://radicale.org/v3.html#configuration
# Default: multifilesystem

filesystem_folder = storage
# Folder for storing local collections, created if not present.
# Default: /var/lib/radicale/collections
```

## Usage ##

Launch Radicale using your preferred method and access the server at: [https://localhost:5232](https://localhost:5232)
 


### Via Docker Compose ###

Create a `docker-compose.yaml` file and place it in the `app` root folder.

```
 /app/
    ├── conf
    │    ├── radicale.cert.pem
    │    ├── radicale.conf
    │    ├── radicale.key.pem
    │    └── users
    ├── docker-compose.yaml
    └── storage
```

`docker-compose.yaml`
```yaml
version: "2.1"
services:
  radicale:
    image: dickflussig/radicale:latest
    container_name: radicale
    environment:
      - PORT=5232
      - TZ=Australia/Brisbane 
    volumes:
      - ./conf:/app/conf:ro
      - ./storage:/app/storage:rw
    ports:
      - 5232:5232/tcp
```
To start `docker-compose` run the following in the `app` root folder. 

```bash
docker-compose up
```

### Via Docker Run ###

If you prefer `docker run` to start the container, run the following in the `app` root folder. 


```bash
docker run --rm \
  -it \
  --name=radicale \
  -p 5232:5232/tcp \
  -e TZ=Australia/Brisbane \
  -v $(pwd)/conf:/app/conf:ro \
  -v $(pwd)/storage:/app/storage:rw \
  dickflussig/radicale:latest
```

## Parameters ##


Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 5232:5232/tcp` would expose port `5232/tcp` from inside the container to be accessible from the host’s IP on port `5232` outside the container.

| Parameter | Function |
| --- | --- |
| `--name=radicale` | Assign a name to the container. |
| `-p 5235:5232/tcp` | Port to publish the WebUI. | 
| `-e TZ=Australia/Brisbane` | Specify a timezone to use. |
| `-v /path/to/conf:/conf:ro` | Bind mount for config files. |
| `-v /path/to/storage:/storage:rw` | Bind mount for Radicale collections. |

## Collection Locking ##

Whether collection data is accessed by hand or external script, the storage must be locked.

- To invoke the lock run: `docker exec radicale sh lock_collection.sh`

This will exclusively lock the collection, run the command again to unlock it.


These files can be excluded using an ignore file such as `.gitignore`.

```
.Radicale.cache
.Radicale.lock
.Radicale.tmp-*
Collection.lock
```

## Support Info ##

- Shell access whilst the container is running: `docker exec -it radicale /bin/sh`
- To monitor the logs of the container in real-time: `docker logs -f radicale`
- View Radicale help with: `docker exec -it radicale python3 -m radicale --help`



## Updating Info ##

This static image requires an image update and container recreation to update the app inside.
Below are the instructions for updating containers:

### Via Docker Compose ###

- Update all images: `docker-compose pull`
    - or update a single image: `docker-compose pull radicale`
    
- Let compose update all containers as necessary: `docker-compose up -d`
    - or update a single container: `docker-compose up -d radicale`
   
- You can also remove the old dangling images: `docker image prune`

### Via Docker Run ###

- Update the image: `docker pull dickflussig/radicale`
- Stop the running container: `docker stop radicale`
- Delete the container: `docker rm radicale`
- You can also remove the old dangling images: `docker image prune`

## Building Locally ##
If you prefer to build the image locally:

```bash
git clone https://github.com/dickflussig/docker-radicale.git
cd docker-radicale
docker build \
  --no-cache \
  --pull \
  -t dickflussig/radicale:latest .
```
