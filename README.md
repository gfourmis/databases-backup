# Databases Backup Linux Script

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



