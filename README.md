# docker-alpine-cron
A Linux Alpine-based image with `dcron`.

Based on https://github.com/xordiv/docker-alpine-cron project which has not been updated in a while.

## Example

1) Build the base image:

```shell
docker build -f apline-cron.Dockerfile . -t corvus/alpine-cron:3.15.0
```

2) Extend the base image:

```Dockerfile
FROM corvus/alpine-cron:3.15.0

RUN apk update && \
    apk add --no-cache mariadb-client
```

3) Set up a Docker Compose file
```yaml
my_container:
  image: agorelyshev/alpine-cron:latest
  restart: unless-stopped
  hostname: backups-cron
  container_name: backups-cron
  volumes:
    - /srv/backups:/backups:rw
    - /srv/database/secrets:/run/secrets:ro
    - ./backup-db.sh:/backup-db.sh:ro
  environment:
    MYSQL_HOSTNAME: my-database
    MYSQL_USERNAME_FILE: /run/secrets/user-name.txt
    MYSQL_PASSWORD_FILE: /run/secrets/user-password.txt
    CRON_STRINGS: "0 */2 * * * bash /backup-db.sh"  # notice this is UTC time
 ```

4) Make sure that `user-name.txt` and `user-password.txt` files exist under `/srv/database` or whatever other secure location.

## Explanation

The example above uses the `alpine-cron` image to automate periodic backups of a MariaDB database.
After we have extended the base image to include the toolset required for such backups, we configure the extended image.
We mount a host volume containing database secrets and another host volume that the container will use to output database dumps.
In addition, we mount a shell script that will:
 - read the mounted secrets,
 - connect to a remote database (possibly, residing in another container), and
 - invoke `mysqldump`, directing its output to `/srv/backus:/backups` 

Finally, we set up a string that the `dcron` daemon will consume, directing the daemon to call our script once every 2 hours.

Note that you can supply multiple Cron strings, if you want to use this container to set up multiple Cron jobs.
Make sure to use the '|'-syntax, because you want to preserve newline characters:

```yaml
CRON_STRINGS: |
    0 */2 * * * bash /do-one-thing.sh
    0 */12 * * * bash /do-another-thing.sh
```
