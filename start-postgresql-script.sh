#!/bin/sh

# This script will be executed once on a `docker run`.

# `/sbin/setuser postgres` runs the given command as the user `postgres`.
# If you omit that part, the command will be run as root.
exec /sbin/setuser postgres service postgresql start