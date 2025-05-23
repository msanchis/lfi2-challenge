# Reto CTF: Vulnerabilidad de Subida de Archivos y Escalada de Privilegios

Este proyecto crea un entorno Docker para practicar técnicas de ciberseguridad, enfocado en la explotación de vulnerabilidades de subida de archivos y escalada de privilegios.

## Configuración

El entorno contiene:
- Un servidor web Apache con PHP
- Una página web vulnerable que permite subir archivos sin restricciones
- Un usuario `user` con id_rsa para conectarse al ssh
- Un usuario `user` con permisos de sudo mal configurados
- Dos archivos objetivo: `/home/user/flag.txt` y `/root/root.txt`

## Puesta en marcha

1. Asegúrate de tener Docker y Docker Compose instalados en tu sistema.

2. Clona este repositorio o copia los archivos `Dockerfile` y `docker-compose.yml` a un directorio.

3. Desde el directorio que contiene los archivos, ejecuta:

```bash
docker-compose up -d
# Segundo reto de tipo LFI con credenciales expuestas para conectar por SSH y escalar privilegios
