#!/bin/bash

# Crear usuario para backup y restore

#use admin;
#db.createUser(
#   {
#     user: "admin_backup_us",
#     pwd: "pass1",
#     roles: [ { role: "backup", db: "admin" } ]
#   }
#);

#use admin;
#db.createUser(
#   {
#     user: "admin_restore_us",
#     pwd: "pass2",
#     roles: [ { role: "restore", db: "admin" } ]
#   }
#);

#db.getUser("admin_backup_us");
#db.getUser("admin_restore_us");
 
TODAY=$(date +"%Y%m%d")
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="/home/ubuntu/backups/database/docdb"
TARGET_DIR="$BACKUP_DIR/$TODAY"
EXT="gz"

DB_HOST=my-cluster.amazonaws.com
DB_PORT=27017
DB_AUTH_NAME=admin

##to-do: obtener listado de bases de datos
##db.adminCommand( { listDatabases: 1, nameOnly: true} )

DB_NAME=app_prd_db
DB_USER=admin_backup_us
DB_PASS="pass1"

SSL_CAFile="/home/ubuntu/.ssh/rds-combined-ca-bundle.pem"

FILE_NAME=$TIMESTAMP-$DB_NAME.$EXT
TARGET_FILE=$TARGET_DIR/$FILE_NAME

mkdir -p $TARGET_DIR
echo "Backup database $DB_NAME in $TARGET_FILE" 
mongodump --ssl --host "$DB_HOST":"$DB_PORT" --sslCAFile "$SSL_CAFile" --db "$DB_NAME" --gzip --archive="$TARGET_FILE" --username "$DB_USER" --password "$DB_PASS"

#Cargar archivo a AWS S3
/usr/local/bin/aws s3 cp $TARGET_FILE s3://my-bucket/backups/databases/docdb/$DB_NAME/$TODAY/

# --expires "$(date -d '+6 months' --utc +'%Y-%m-%dT%H:%M:%SZ')"

# /bin/rm -rf $TARGET_DIR
echo "Deleting old files in $BACKUP_DIR"
find $BACKUP_DIR/* -type d -ctime +7 -exec rm -rf {} \;

# RESTORE
#DB_INCLUD_PATTERN='my_src_db.*'
#DB_SOURCE_PATTERN='my_src_db.*'
#DB_TARGET_PATTERN='my_trg_db.*'
# mongorestore --ssl --host "$DB_HOST":"$DB_PORT" --sslCAFile "$SSL_CAFile" --authenticationDatabase="DB_AUTH_NAME" --username "$DB_USER" --password "$DB_PASS" --nsInclude "$DB_INCLUD_PATTERN" --nsFrom "$DB_SOURCE_PATTERN" --nsTo "$DB_TARGET_PATTERN" --gzip --archive="$TARGET_FILE"
