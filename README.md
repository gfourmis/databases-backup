# Databases Backup Linux Script

## Crear usuario para copias de seguridad

```
mysql -u root -p
# SET GLOBAL validate_password_policy = LOW;
CREATE USER 'backups'@'localhost' IDENTIFIED BY 'my-password';
GRANT SELECT, RELOAD, EVENT, LOCK TABLES, PROCESS, REFERENCES, SELECT, SHOW DATABASES, SHOW VIEW, REPLICATION CLIENT, TRIGGER ON *.* TO 'backups'@'localhost' ;
quit
```

## Configurar credenciales de MySql
```
nano ~/.my.cnf
```

```
[client]
user = backups
password = my-password
host = my-host
```

```
chmod go-rw ~/.my.cnf
```

## Crear directorios
```
cd ~
mkdir -p scripts/backups
mkdir -p backups/databases
```

## Obtener script
```
cd ~/scripts/backups
git clone https://github.com/gfourmis/databases-backup.git
cd databases-backup
```
## Editar configuración
```
cp run-example.conf run.conf
```
```
nano run.conf
```

## Asignar permisos al script
```
chmod +x run.sh
```

## Ejecutar script
```
./run.sh
```

## Listar archivos
```
ls -lh ~/backups/
```

## Configurar destino
Previamente **se debe configurar _AWS cli_** para poder subir los archivos a *AWS S3* en lo posible no almacenar los archivos en ~~local~~.

## Configurar tareas programadas
```
crontab -e
```
Todos los días a la 1am
> 0 1 * * * /bin/bash /home/ubuntu/scripts/databases-backup.sh



