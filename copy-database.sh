#!/bin/bash
# Purpose = Backup and restore MySql database an other MySql database
# Created on 10-08-2020
# Author = frojas
# Version 1.0

## Backup source databae
# mysqldump -u root -p database_name | mysql -h remote_host -u root -p remote_database_name

#START

## Definir ruta de los ejecutables
GZIP=/bin/gzip
MYSQLDUMP=/usr/bin/mysqldump
MYSQL=/usr/bin/mysql

## Definir variables
FILEEXT=sql
DATE=$(date +"%F")
DATETIME=`date +%Y%m%d-%H%M%S`

#Definir directorios
TMPDIR=/tmp
TRGDIR=~/backups/database
BCKDIR=$TRGDIR/$DATE

# Definir base de datos origen
SOURCE_HOST=peripliaapidbcluster.cluster-cifp7ibxqe4n.us-east-1.rds.amazonaws.com
SOURCE_USER=peripliadevmt
SOURCE_DATABASE=peripliaapp_app

# Definir base de datos destino
TARGET_HOST=peripliaapidbcluster.cluster-cifp7ibxqe4n.us-east-1.rds.amazonaws.com
TARGET_USER=peripliadevmt
TARGET_DATABASE=peripliaapp_prd

# Ir al directorio temporal
cd $TMPDIR

# Crear directorio de salida
finalpath=$BCKDIR
mkdir -p $finalpath

# Definir nombre del archivo    
filename=$DATETIME-$SOURCE_DATABASE.$FILEEXT
destination=$finalpath/$filename

echo "Dumping database $SOURCE_DATABASE"
$MYSQLDUMP -u $SOURCE_USER -p -h $SOURCE_HOST $SOURCE_DATABASE > $destination

# Validar salida del comando anterior
status=$?
if test $status -eq 0
then
	echo "Success dumping!"

	# Listar archivo
	ls -lh $destination
	
	# Eliminar la base de datos destino
	echo "Dropping and creating database $TARGET_DATABASE"
	$MYSQL -u $TARGET_USER -p -h $TARGET_HOST -e "DROP DATABASE $TARGET_DATABASE;CREATE DATABASE $TARGET_DATABASE;"
	
	status=$?
	if test $status -eq 0
	then
		
		echo "Success droping and creating!"

		echo "Restoring database $SOURCE_DATABASE into $TARGET_DATABASE"
		$MYSQL -u $TARGET_USER -p -h $TARGET_HOST $TARGET_DATABASE < $destination
		
		status=$?
		if test $status -eq 0
		then
			echo "Success restoring!"
		fi
	fi
fi	


#mysqldump -u peripliadevmt -p -h peripliaapidbcluster.cluster-cifp7ibxqe4n.us-east-1.rds.amazonaws.com peripliaapp_app_dw > ~/backups/database/$(date +%F_%H%M%S)-peripliaapp_app_dw.sql
#    mysql -u peripliadevmt -p -h peripliaapidbcluster.cluster-cifp7ibxqe4n.us-east-1.rds.amazonaws.com peripliaapp_prd_dw < ~/backups/database/ 2020-08-06_213854-peripliaapp_app_dw.sql