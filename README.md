# Quick reference

  - Supported architectures: amd64, arm32v7, arm64v8
  - [GitHub repository](https://github.com/josebamartos/certbot-dns-gandi)

# What is certbot-dns-gandi?

It is a tool for requesting new SSL certificates from Let's Encrypt. It does the DNS challenge for validation and manages the creation and deletion of the temporary DNS records through Gandi's LiveDNS API.

# How to use this image

This image is based on [certbot/certbot](https://hub.docker.com/r/certbot/certbot) and includes the required bash script set to make the DNS challenge against Gandi's LiveDNS API and get new SSL certificate files from Let's Encrypt. Containers based on this image must be configured using environment variables or a environment file. A sample of the environment file is present in the repository.

## Configuration

### Environment file

To customize the configuration of the httpd server, copy file `certbot-dns-gandi.env.sample` to `certbot-dns-gandi.env`: 

```console
$ cp certbot-dns-gandi.env.sample certbot-dns-gandi.env
```
And open it for configuration:
```console
$ vim certbot-dns-gandi.env
```

```console
DOMAIN=domain.com  
EMAIL=user@domain.com  
CHALLENGE_TTL=300  
CHALLENGE_WAIT=30  
GANDI_API_KEY=ab01cd02de03fg04hi05jk06  
DAYS_REMAINING=28
CHECK_EXPIRY=false
STAGING=false  
DRY_RUN=false  
```
Containers can be configured using the environment file. All the parameters are shown in the table below.

| Parameter      | Description |
| -------------  | ----------- |
| DOMAIN         | Domain/subdomain to be secured with SSL certificated   |
| EMAIL          | Email address for important account notifications      |
| CHALLENGE_TTL  | TTL of the temporary record used for the DNS challenge |
| CHALLENGE_WAIT | Seconds to wait for DNS propagation after creating the temporary record and before starting validation challenge |
| GANDI_API_KEY  | API key created in [Gandi Account](https://account.gandi.net/)         |
| DAYS_REMAINING | Days before expiry date when new certificates will be requested        |
| CHECK_EXPIRY   | If true, checks the remaining days of the current certificate and aborts the request when it's greater than `DAYS_REMAINING` |
| STAGING        | Use the staging server to obtain or revoke test (invalid) certificates |
| DRY_RUN        | Run without saving any certificates                                    |

### Bind mounts and volumes

SSL certificates are created in `challenge/certs`. You must bind mount this path or use volumes to get them.

## Use cases

### Request  staging certificates for yourdomain.com

To request staging certificates for `yourdomain.com`. It's recommended to request staging certificates before requesting the production ones to fix errors or misconfigurations. Production certificate generation has limits.

certbot-dns-gandi.env:

```console
DOMAIN=yourdomain.com
EMAIL=admin@yourdomain.com
CHALLENGE_TTL=300
CHALLENGE_WAIT=30
GANDI_API_KEY=ab01cd02de03fg04hi05jk06
DAYS_REMAINING=28
CHECK_EXPIRY=true
STAGING=true
DRY_RUN=false
```
Run a new container:

```console
$ docker run --rm  --env-file  /home/user/certbot-dns-gandi/certbot-dns-gandi.env -v /home/user/certs:/challenge/certs josebamartos/certbot-dns-gandi
```


### Request  production certificates for yourdomain.com

If you want to request production certificates for `yourdomain.com`:

certbot-dns-gandi.env:

```console
DOMAIN=yourdomain.com
EMAIL=admin@yourdomain.com
CHALLENGE_TTL=300
CHALLENGE_WAIT=30
GANDI_API_KEY=ab01cd02de03fg04hi05jk06
DAYS_REMAINING=28
CHECK_EXPIRY=true
STAGING=false
DRY_RUN=false
```
Run a new container:

```console
$ docker run --rm  --env-file  /home/user/certbot-dns-gandi/certbot-dns-gandi.env -v /home/user/certs:/challenge/certs josebamartos/certbot-dns-gandi
```

### Request  production wildcard certificates for subdomains

If you have several subdomains, you may prefer to create a [wildcard certificate](wikipedia) because you can use it to secure all the subdomains. To request a wildcard certificate, just append `*.` to the domain name.

```console
DOMAIN=*.domain.com
EMAIL=user@domain.com
CHALLENGE_TTL=300
CHALLENGE_WAIT=30
GANDI_API_KEY=ab01cd02de03fg04hi05jk06
DAYS_REMAINING=28
CHECK_EXPIRY=true
STAGING=false
DRY_RUN=false
```
Run a new container:

```console
$ docker run --rm  --env-file  /home/user/certbot-dns-gandi/certbot-dns-gandi.env -v /home/user/certs:/challenge/certs josebamartos/certbot-dns-gandi
```

# License
certbot-gandi-dns is a program to request SSL certificates from Let's Encrypt for domains hosted in Gandi.net.
Copyright (C) 2020  Joseba Martos <https://otzarri.net>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
