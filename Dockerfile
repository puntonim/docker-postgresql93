# Use phusion/baseimage as base image. To make your builds reproducible, make
# sure you lock down to a specific version, not to `latest`!
# See https://github.com/phusion/baseimage-docker/blob/master/Changelog.md for
# a list of version numbers.
FROM phusion/baseimage:0.9.15

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# ideal solution is to change to devmapper for storage 
# add the following line to /etc/docker/default
# DOCKER_OPTS="--storage-driver=devicemapper"
# then restart the docker service
# see here if you have existing containers you need to backup
# http://muehe.org/posts/switching-docker-from-aufs-to-devicemapper/

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

##################################################################################################
## START CUSTOMIZATION

# Create a mount point
VOLUME ["/srv/pgdata"]

# Install PostgreSQL 9.3.
RUN apt-get update
RUN apt-get install -y postgresql-9.3

# work around for AUFS bug
# as per https://github.com/docker/docker/issues/783#issuecomment-56013588
RUN echo "mkdir /etc/ssl/private-copy; mv /etc/ssl/private/* /etc/ssl/private-copy/; rm -r /etc/ssl/private; mv /etc/ssl/private-copy /etc/ssl/private; chmod -R 0700 /etc/ssl/private; chown -R postgres /etc/ssl/private" >> /etc/my_init.d/00_regen_ssh_host_keys.sh

# Adjust PostgreSQL configuration so that remote connections to the database are possible.
# Note: this is not a security threat because the port 5432 is firewalled in the host machine.
RUN echo "host all all 0.0.0.0/0 md5" >> /etc/postgresql/9.3/main/pg_hba.conf
# And add 'listen_addresses' to '/etc/postgresql/9.3/main/postgresql.conf'.
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# Expose SSH and PostgreSQL ports.
EXPOSE 5432 22

# Add the PostgreSQL start script (executed on a `docker run`).
ADD start-postgresql-script.sh /etc/my_init.d/01_start_postgresql.sh
RUN chmod +x /etc/my_init.d/01_start_postgresql.sh

# Add the init-container script (executed on a `docker run`).
ADD init-container-script.sh /etc/my_init.d/02_init_container.sh
RUN chmod +x /etc/my_init.d/02_init_container.sh

## END CUSTOMIZATION
##################################################################################################


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


###################################################################################################
## HOW TO USE IT
#
# BUILD
# =====
#   $ docker build -t nimiq/postgresql .
#
# RUN
# ===
# ARGUMENTS
#   -p 2223:22
#       Port 22 (SSH) in the container will be exposed to port 2223 in the host.
#       You can use the host port 2223 or any other port, but you must use the container port 22.
#   -p 5432:5432
#       Port 5432 (PostgreSQL) in the container will be exposed to port 5432 in the host.
#       You can use the host port 5432 or any other port, but you must use the container port 5432.
#   --volume=/mylocaldir:/srv/pgdata
#       The dir /mylocaldir in the host will be mounted to /srv/pgdata in the container.
#       You can use the local dir /mylocaldir or any other dir, but you must use the container dir /srv/pgdata.
#   -e "PG_USERNAME=myuser"
#       The username to be used when creating a new ROLE in PostgreSQL.
#   -e "PG_PASSWORD=mypass"
#       The password to be used when creating a new ROLE in PostgreSQL.
#   -e "SSH_PUBLIC_KEY=..."
#       The SSH public key to be added to the authorized_keys file in order to accept SSH connections.
#
# EXAMPLES:
#   $ docker run -d -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/srv/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=..." nimiq/postgresql
# 
# A more user-friendly input of the public SSH key:
#   $ read MY_SSH_KEY < ~/.ssh/id_rsa.pub
#   $ docker run -d -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/srv/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=$MY_SSH_KEY" nimiq/postgresql
#     
# Run a one-shot interactive shell:
#   $ read MY_SSH_KEY < ~/.ssh/id_rsa.pub
#   $ docker run -ti --rm -p 2223:22 -p 5432:5432 --name postgresql --volume=/mylocaldir:/srv/pgdata -e "PG_USERNAME=myuser" -e "PG_PASSWORD=mypass" -e "SSH_PUBLIC_KEY=$MY_SSH_KEY" nimiq/postgresql /sbin/my_init -- bash
#
# To test the PostgreSQL server, you can run from the host:
#     psql -h localhost -p 5432 -U myuser myuser
#
# START/STOP
# ==========
#   $ docker start postgresql
#   $ docker stop postgresql
