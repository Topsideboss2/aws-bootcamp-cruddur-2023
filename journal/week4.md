# Week 4 — Postgres and RDS

## Topics
* [Launch Postgres locally via a container]()
* [Bash scripting for common database actions]()
* [Seed Postgres Database table with data]()
* [Provision an RDS Postgres instance]()
* [Install Postgres Driver in Backend Application]()
* [Create new activities with a database insert]()

## Launch Postgres Locally

Already had postgres configured in `.gitpod.yml` file:
```yaml
  - name: postgres
    init: |
      curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg
      echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" |sudo tee  /etc/apt/sources.list.d/pgdg.list
      sudo apt update
      sudo apt install -y postgresql-client-13 libpq-dev
```
This was later modified by adding a couple of commands:
```yaml
    command: |
      export GITPOD_IP=$(curl ifconfig.me)
      source "$THEIA_WORKSPACE_ROOT/backend-flask/bin/db-update-sg-rule"
```
The `export GITPOD_IP=$(curl ifconfig.me)` will save our gitpod ip address. It is useful because it allows us to keep changing our gitpod ip on AWS security group associated with our RDS.

Also, the docker configuration is found in `/dockercompose.yml` will allow us to launch a container that runs postgres client image:
```yaml
...
db:
  image: postgres:13-alpine
  restart: always
  environment:
    - POSTGRES_USER=postgres
    - POSTGRES_PASSWORD=password
  ports:
    - '5432:5432'
  volumes:
    - db:/var/lib/postgresql/data
...
volumes:
  db:
    driver: local
```

To launch postgres locally while creating a database called `cruddur`, run the following commands:
```shell
psql -U postgres -h localhost
# password is 'password'
\l # list all databases 
```
output:
![]()
```shell
CREATE DATABASE cruddur; # NOW, create the new cruddur db.
\l # list all databases 
```
output:
![]()
```shell
DROP DATABASE cruddur; # drop cruddur db if it exist.
\l # list all databases
```
output:
![]()

To launch an RDS instance that uses Postgres through AWS CLI, run the following command:
```shell
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 14.6 \
  --master-username root \
  --master-user-password ****** \  # Needs to be at least 8 printable ASCII characters. Can't contain any of the following: / (slash), '(single quote), "(double quote) and @ (at sign).# 
  --availability-zone us-east-1a \
  --allocated-storage 20 \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
```
We will now create scripts to connect to our database, create a database, drop a database, load a schema, seed data, list sessions, and update our gitpod ip.
First, save these environment variables that we will need:
```shell
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"

export PROD_CONNECTION_URL="postgresql://root:***@cruddur-db-instance.c0jj0dvjjrlg.us-east-1.rds.amazonaws.com:5432/cruddur"
gp env PROD_CONNECTION_URL="postgresql://postgres::***@cruddur-db-instance.c0jj0dvjjrlg.us-east-1.rds.amazonaws.com:5432/cruddur"

export DB_SG_ID="sg-03612a80ef9ea9c32"
gp env DB_SG_ID="sg-03612a80ef9ea9c32"
export DB_SG_RULE_ID="sgr-000875ae83d6cc004"
gp env DB_SG_RULE_ID="sgr-000875ae83d6cc004"
```

#### `db-connect`
```shell
#!/usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-connect"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  CON_URL=$PROD_CONNECTION_URL
else
  echo "Not running in production mode"
  CON_URL=$CONNECTION_URL
fi

psql $CON_URL
```

#### `db-create`
```shell
#!/usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-create"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<< "$CONNECTION_URL")

psql $NO_DB_CONNECTION_URL -c "CREATE DATABASE cruddur;"
```
#### `db-drop`
```shell
#!/usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-drop"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"


NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<< "$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "DROP DATABASE cruddur;"

```
#### `db-schema-load`
```shell
#!/usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

schema_path="$(realpath ..)/db/schema.sql"

if [ "$1" = "prod" ]; then
    echo "This is the production environment."
    CON_URL="$PROD_CONNECTION_URL"
else
    echo "This is not the production environment."
    CON_URL="$CONNECTION_URL"
fi

psql $CON_URL cruddur < $schema_path
```
#### `db-seed`
```shell
#!/usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-seed"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

seed_path="$(realpath ..)/db/seed.sql"

if [ "$1" = "prod" ]; then
    echo "This is the production environment."
    CON_URL="$PROD_CONNECTION_URL"
else
    echo "This is not the production environment."
    CON_URL="$CONNECTION_URL"
fi

psql $CON_URL cruddur < $seed_path
```
#### `db-sessions`
```shell
#!/usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="active sessions-"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

if [ "$1" = "prod" ]; then
    echo "This is the production environment."
    CON_URL="$PROD_CONNECTION_URL"
else
    echo "This is not the production environment."
    CON_URL="$CONNECTION_URL"
fi

NO_DB_CON_URL=$(sed 's/\/cruddur//g' <<<"$CON_URL")
psql $NO_DB_CON_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```
#### `db-setup`
```shell
#!/usr/bin/bash
-e

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

source "db-drop"
source "db-create"
source "db-schema-load"
source "db-seed"
source "db-sessions"
```
#### `db-update-sg-rule`
```shell
#!/usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-update-sg-rule"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

aws ec2 modify-security-group-rules \
     --group-id $DB_SG_ID \
      --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={Description=GITPOD,IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```

