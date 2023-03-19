# Week 4 — Postgres and RDS

## Topics
* [Launch Postgres locally via a container](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week4.md#launch-postgres-locally)
* [Provision an RDS Postgres instance using AWS CLI](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week4.md#provision-an-rds-postgres-instance-using-aws-cli)
* [Bash scripting for common database actions](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week4.md#bash-scripting-for-common-database-actions)
* [Install Postgres Driver in Backend Application](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week4.md#install-postgres-driver-in-backend-application)
* [Create a Lambda Function](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week4.md#create-a-lambda-function)
* [Created Congito Trigger to insert user into database](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week4.md#create-congito-trigger-to-lambda)
* [Create new activities with a database insert](https://github.com/Topsideboss2/aws-bootcamp-cruddur-2023/blob/main/journal/week4.md#create-new-activities-with-a-database-insert)

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

```shell
CREATE DATABASE cruddur; # NOW, create the new cruddur db.
\l # list all databases 
```

```shell
DROP DATABASE cruddur; # drop cruddur db if it exist.
\l # list all databases
```

## Provision an RDS Postgres instance using AWS CLI
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

Next, save these environment variables that we will need:
```shell
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"

export PROD_CONNECTION_URL="postgresql://root:***@cruddur-db-instance.*********.us-east-1.rds.amazonaws.com:5432/cruddur"
gp env PROD_CONNECTION_URL="postgresql://postgres::***@cruddur-db-instance.*********.us-east-1.rds.amazonaws.com:5432/cruddur"

export DB_SG_ID="sg-03612a80ef9ea9c32"
gp env DB_SG_ID="sg-03612a80ef9ea9c32"
export DB_SG_RULE_ID="sgr-000875ae83d6cc004"
gp env DB_SG_RULE_ID="sgr-000875ae83d6cc004"
```
We will add the environment variable `$CONNECTION_URL` to `docker-compose.yml`:
```yaml
  backend-flask:
    environment:
      CONNECTION_URL: "${CONNECTION_URL}"
```

## Bash scripting for common database actions

We will now create scripts to connect to our database, create a database, drop a database, load a schema, seed data, list sessions, and update our gitpod ip.
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
![](../_docs/assets/db-update-gitpod-ip.png)

Make the shell scripts executables:
```shell
chmod u+x db-connect db-create db-drop db-update-sg-rule db-seed db-sessions db-schema-load db-setup
```
Add file `/backend-flask/db/schema.sql` that will create our schema for the databases:
```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

DROP TABLE IF EXISTS public.users;
DROP TABLE IF EXISTS public.activities;

CREATE TABLE public.users (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  display_name text NOT NULL,
  handle text NOT NULL,
  email text,
  cognito_user_id text NOT NULL,
  created_at TIMESTAMP default current_timestamp NOT NULL
);

CREATE TABLE public.activities (
  uuid UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_uuid UUID NOT NULL,
  message text NOT NULL,
  replies_count integer DEFAULT 0,
  reposts_count integer DEFAULT 0,
  likes_count integer DEFAULT 0,
  reply_to_activity_uuid integer,
  expires_at TIMESTAMP,
  created_at TIMESTAMP default current_timestamp NOT NULL
);
```

Add another file `/backend-flask/db/seed.sql` that will seed data into our database after creating the schema:
```sql
-- this file was manually created
INSERT INTO public.users (display_name, handle, email, cognito_user_id)
VALUES
  ('Andrew Brown', 'andrewbrown' , 'andrew@exampro.co' , 'MOCK'),
  ('Mark Kibara', 'topsideboss2', 'markkibara2014@gmail.com', 'MOCK'),
  ('Andrew Bayko', 'bayko' , 'andrewbayko@exampro.co' , 'MOCK');

INSERT INTO public.activities (user_uuid, message, expires_at)
VALUES
  (
    (SELECT uuid from public.users WHERE users.handle = 'topsideboss2' LIMIT 1),
    'Hey everyone, welcome to my Cruddur Web App!',
    current_timestamp + interval '10 day'
  )
```

Add another file `backend-flask/db/sql/activities/create.sql` that will be used to create an activity:
```sql
INSERT INTO public.activities (
   user_uuid,
   message,
   expires_at
 )
 VALUES (
   (SELECT uuid 
     FROM public.users 
     WHERE users.handle = %(handle)s
     LIMIT 1
   ),
   %(message)s,
   %(expires_at)s
 ) RETURNING uuid;
```

Add another file `backend-flask/db/sql/activities/home.sql` that will be used for home page:
```sql
SELECT
   activities.uuid,
   users.display_name,
   users.handle,
   activities.message,
   activities.replies_count,
   activities.reposts_count,
   activities.likes_count,
   activities.reply_to_activity_uuid,
   activities.expires_at,
   activities.created_at
 FROM public.activities
 LEFT JOIN public.users ON users.uuid = activities.user_uuid
 ORDER BY activities.created_at DESC
```
Add another file `backend-flask/db/sql/activities/object.sql` that will be used for objects:
```sql
SELECT
   activities.uuid,
   users.display_name,
   users.handle,
   activities.message,
   activities.created_at,
   activities.expires_at
 FROM public.activities
 INNER JOIN public.users ON users.uuid = activities.user_uuid 
 WHERE 
   activities.uuid = %(uuid)s
```

Try to connect to local database 
```shell
cd backend-flask/bin/
source db-connect
```
Output for local Database:
![](../_docs/assets/db-setup.png)

Try to connect to RDS database
```shell
cd backend-flask/bin/
source db-connect prod
```
Output for RDS:
![](../_docs/assets/db-setup(prod).png)
## Configure Postgres Driver (Psycopg3) in Backend Application

First, install the driver using pip by including it in the `/backend-flask/requirements.txt`
```
psycopg[binary]
psycopg[pool]
```
Run `pip install -r backend-flask/requirements.txt`

We will utilize connection pulling so that we cannot run out of connections when users are using the database.
Create a file `/backend-flask/lib/db.py` and add the following python code:
```python
from psycopg_pool import ConnectionPool
import os
import re
import sys
from flask import current_app as app

class Db:
  def __init__(self):
    self.init_pool()

  def template(self,*args):
    pathing = list((app.root_path,'db','sql',) + args)
    pathing[-1] = pathing[-1] + ".sql"

    template_path = os.path.join(*pathing)

    green = '\033[92m'
    no_color = '\033[0m'
    print("\n")
    print(f'{green} Load SQL Template: {template_path} {no_color}')

    with open(template_path, 'r') as f:
      template_content = f.read()
    return template_content

  def init_pool(self):
    connection_url = os.getenv("CONNECTION_URL")
    self.pool = ConnectionPool(connection_url)
  # we want to commit data such as an insert
  # be sure to check for RETURNING in all uppercases
  def print_params(self,params):
    blue = '\033[94m'
    no_color = '\033[0m'
    print(f'{blue} SQL Params:{no_color}')
    for key, value in params.items():
      print(key, ":", value)

  def print_sql(self,title,sql):
    cyan = '\033[96m'
    no_color = '\033[0m'
    print(f'{cyan} SQL STATEMENT-[{title}]------{no_color}')
    print(sql)
  def query_commit(self,sql,params={}):
    self.print_sql('commit with returning',sql)

    pattern = r"\bRETURNING\b"
    is_returning_id = re.search(pattern, sql)

    try:
      with self.pool.connection() as conn:
        cur =  conn.cursor()
        cur.execute(sql,params)
        if is_returning_id:
          returning_id = cur.fetchone()[0]
        conn.commit() 
        if is_returning_id:
          return returning_id
    except Exception as err:
      self.print_sql_err(err)
  # when we want to return a json object
  def query_array_json(self,sql,params={}):
    self.print_sql('array',sql)

    wrapped_sql = self.query_wrap_array(sql)
    with self.pool.connection() as conn:
      with conn.cursor() as cur:
        cur.execute(wrapped_sql,params)
        json = cur.fetchone()
        return json[0]
  # When we want to return an array of json objects
  def query_object_json(self,sql,params={}):

    self.print_sql('json',sql)
    self.print_params(params)
    wrapped_sql = self.query_wrap_object(sql)

    with self.pool.connection() as conn:
      with conn.cursor() as cur:
        cur.execute(wrapped_sql,params)
        json = cur.fetchone()
        if json == None:
          "{}"
        else:
          return json[0]
  def query_wrap_object(self,template):
    sql = f"""
    (SELECT COALESCE(row_to_json(object_row),'{{}}'::json) FROM (
    {template}
    ) object_row);
    """
    return sql
  def query_wrap_array(self,template):
    sql = f"""
    (SELECT COALESCE(array_to_json(array_agg(row_to_json(array_row))),'[]'::json) FROM (
    {template}
    ) array_row);
    """
    return sql
  def print_sql_err(self,err):
    # get details about the exception
    err_type, err_obj, traceback = sys.exc_info()

    # get the line number when exception occured
    line_num = traceback.tb_lineno

    # print the connect() error
    print ("\npsycopg ERROR:", err, "on line number:", line_num)
    print ("psycopg traceback:", traceback, "-- type:", err_type)

    # print the pgcode and pgerror exceptions
    print ("pgerror:", err.pgerror)
    print ("pgcode:", err.pgcode, "\n")

db = Db()
```
## Create a Lambda Function
We create a Lambda function that is used to request the new user data -orchestrated using AWS Cognito  passed down to the RDS instance.
The handler function is stored in `aws/json/lambda/cruddur-post-confirmation`file:
```python
import json
import psycopg2
import os

def lambda_handler(event, context):
    user = event['request']['userAttributes']
    print('userAttributes')
    print(user)

    user_display_name  = user['name']
    user_email         = user['email']
    user_handle        = user['preferred_username']
    user_cognito_id    = user['sub']
    try:
      print('entered-try')
      sql = f"""
         INSERT INTO public.users (
          display_name, 
          email,
          handle, 
          cognito_user_id
          ) 
        VALUES(%s,%s,%s,%s)
      """
      print('SQL Statement ----')
      print(sql)
      conn = psycopg2.connect(os.getenv('CONNECTION_URL'))
      cur = conn.cursor()
      params = [
        user_display_name,
        user_email,
        user_handle,
        user_cognito_id
      ]
      cur.execute(sql,*params)
      conn.commit() 

    except (Exception, psycopg2.DatabaseError) as error:
      print(error)
    finally:
      if conn is not None:
          cur.close()
          conn.close()
          print('Database connection closed.')
    return event
```

![](../_docs/assets/AWS-Lambda-Function.png)

***NB:*** The lambda is created in the same VPC as the rds instance. It uses Python 3.8.
Env variables passed are `$CONNECTION_URL` which links it to the rds instance. Architecture is x86_64. To the security group (default), allow port 5432 to the Gitpod Instance. 

![](../_docs/assets/AWS-Lambda-SG.png)

The layer added to our Lambda is the psycopg2 library for Python shown below
```
arn:aws:lambda:us-east-1:898466741470:layer:psycopg2-py38:2
```
![](../_docs/assets/AWS-Lambda-Layer.png)

Now we need to add permissions to our lambda, create a policy that will allow it to attach a NIC to each AZ. Now attach that policy to our Lambda Function
![](../_docs/assets/AWS-Lambda-Policy.png)

![](../_docs/assets/AWS-Lambda-Permissions.png)

## Create Congito Trigger to Lambda
Under the user pool properties of Amazon Cognito, add the function as a Post Confirmation lambda trigger.
The account needs to be removed from AWS Cognito and recreated from Cruddur in order to test that the user is in fact inserted into the AWS RDS database.

![](../_docs/assets/AWS-Cognito-Lambda-Trigger.png)

## Create new activities with a database insert
We need to be able to create a crud and insert into the RDS. To do this, we need to configure `backend-flask/services/create_activity.py`.
This was not easy even following through. I decided to change the hard coded 'MOCK' data to include my cruds.

![](../_docs/assets/Crud2.png)

![](../_docs/assets/Crud.png)