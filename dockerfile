# Dockerfile para crear un reto de seguridad CTF
FROM ubuntu:20.04

# Evitar interacciones durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualizar e instalar paquetes necesarios
RUN apt-get update && apt-get install -y \
    apache2 \
    php \
    libapache2-mod-php \
    sudo \
    vim \
    openssh-server \
    curl \
    iputils-ping \
    net-tools \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configurar apache y php
RUN a2enmod php7.4

# Configurar SSH
RUN mkdir -p /var/run/sshd
RUN echo 'root:toor' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Crear usuarios
RUN useradd -m -s /bin/bash user && echo "user:password123" | chpasswd
RUN useradd -m -s /bin/bash www-data || echo "www-data ya existe"

# Crear archivos objetivo
RUN echo "FLAG{c0ngr4ts_y0u_f0und_the_fl4g}" > /home/user/flag.txt
RUN echo "FLAG{r00t_h4s_b33n_pwn3d}" > /root/root.txt
RUN chmod 400 /home/user/flag.txt
RUN chmod 400 /root/root.txt

# Configurar el directorio web con la vulnerabilidad de subida de archivos
RUN mkdir -p /var/www/html/uploads
RUN chmod 777 /var/www/html/uploads

# Crear una página de subida de archivos vulnerable
RUN echo '<?php \n\
if(isset($_FILES["fileToUpload"])) { \n\
    $target_dir = "uploads/"; \n\
    $target_file = $target_dir . basename($_FILES["fileToUpload"]["name"]); \n\
    if(move_uploaded_file($_FILES["fileToUpload"]["tmp_name"], $target_file)) { \n\
        echo "El archivo ". basename( $_FILES["fileToUpload"]["name"]). " ha sido subido."; \n\
    } else { \n\
        echo "Ha ocurrido un error al subir el archivo."; \n\
    } \n\
} \n\
?> \n\
<!DOCTYPE html> \n\
<html> \n\
<body> \n\
<h2>Subir Archivo</h2> \n\
<form action="" method="post" enctype="multipart/form-data"> \n\
    Selecciona un archivo: \n\
    <input type="file" name="fileToUpload" id="fileToUpload"> \n\
    <br><br> \n\
    <input type="submit" value="Subir Archivo" name="submit"> \n\
</form> \n\
</body> \n\
</html>' > /var/www/html/index.php

# Establecer permisos www-data
RUN chown -R www-data:www-data /var/www/html/

# Configurar sudoers para la vulnerabilidad de escalada de privilegios
RUN echo "www-data ALL=(ALL) NOPASSWD: /usr/bin/vim" >> /etc/sudoers

# Crear un script de puerta trasera
RUN echo '#!/bin/bash \n\
/bin/bash' > /usr/local/bin/backdoor.sh
RUN chmod 755 /usr/local/bin/backdoor.sh
RUN chown www-data:www-data /usr/local/bin/backdoor.sh

# Exponer puertos
EXPOSE 80 22

# Iniciar servicios
CMD service apache2 start && service ssh start && tail -f /dev/null
