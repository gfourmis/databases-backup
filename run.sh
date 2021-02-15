#!/bin/bash
#Purpose = Backup of Important Databases
#Created on 26-01-2019
#update on 15-02-2021
#Author = frojas
#Version 1.0

#START

#Definir ruta de los ejecutables
GZIP=/bin/gzip
MYSQLDUMP=/usr/bin/mysqldump
MYSQL=/usr/bin/mysql

#Definir variables
FILEEXT=sql.gz
DATE=$(date +"%F")
MYSQL_CONFIG_FILE=~/.my.cnf
SCRIPT_CONFIG_FILE=run.conf
AWS_BIN=/usr/local/bin/aws

#Definir directorios
TMPDIR=/tmp
TRGDIR=~/backups/databases

# Cargar parametros
source $SCRIPT_CONFIG_FILE
BCKDIR=$TRGDIR/$DATE
BUCKET_PATH=$BUCKET_NAME/$BUCKET_DIR

# Ir al directorio temporal
cd $TMPDIR

#Obtener nombre de las bases de datos
databases=`$MYSQL --defaults-extra-file=$MYSQL_CONFIG_FILE -e "SHOW DATABASES;" | grep -Ev "(Database|information_schema|performance_schema|mysql|phpmyadmin|sys)"`

# Crear directorio de salida
finalpath=$BCKDIR
mkdir -p $finalpath

#Recorrer elementos
for database in $databases; do
       
	DATETIME=`date +%Y%m%d-%H%M%S`
	filename=$DATETIME-$database.$FILEEXT
	destination=$finalpath/$filename

	echo "Dumping database: $database"
	$MYSQLDUMP --defaults-extra-file=$MYSQL_CONFIG_FILE --force --opt --databases $database | $GZIP > $destination
	$GZIP -t $destination && echo OK || echo FAIL		
	# Validar salida del comando anterior
	status=$?
	if test $status -eq 0
	then
		echo "Uploading $filename"
		$AWS_BIN s3 cp $destination s3://$BUCKET_PATH/$database/$DATE/
	fi	
	
done

# Listar archivos
ls -lh $finalpath

echo "Deleting old files in $TRGDIR"
find $TRGDIR/* -type d -ctime +7 -exec rm -rf {} \;

# Listar directorios
ls -lh $TRGDIR

#Descomprimir
#gunzip < [backupfile.sql.gz] | mysql -u [uname] -p[pass] [dbname]
#gunzip [backupfile.sql.gz]
#mysql -u [uname] -p[pass] [dbname] < [backupfile.sql]
