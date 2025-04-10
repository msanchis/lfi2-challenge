# Dockerfile para crear un reto de seguridad CTF
FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

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
    openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN a2enmod php7.4

# Configurar SSH
RUN mkdir -p /var/run/sshd
RUN echo 'root:toor' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
RUN sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Crear usuarios
RUN useradd -m -s /bin/bash user && echo "user:password123" | chpasswd

# Crear clave SSH para user
RUN mkdir -p /home/user/.ssh && \
    ssh-keygen -t rsa -b 2048 -f /home/user/.ssh/id_rsa -N "" && \
    cat /home/user/.ssh/id_rsa.pub > /home/user/.ssh/authorized_keys && \
    chown -R user:user /home/user/.ssh && \
    chmod 700 /home/user/.ssh && \
    chmod 600 /home/user/.ssh/authorized_keys

# Opcional: Mostrar la clave privada en el build output
RUN echo "===== PRIVATE KEY =====" && cat /home/user/.ssh/id_rsa

RUN echo "FLAG{c0ngr4ts_y0u_f0und_the_fl4g}" > /home/user/flag.txt
RUN echo "FLAG{r00t_h4s_b33n_pwn3d}" > /root/root.txt
RUN chmod 400 /home/user/flag.txt
RUN chmod 400 /root/root.txt

RUN mkdir -p /var/www/html/uploads
RUN chmod 777 /var/www/html/uploads

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

RUN chown -R www-data:www-data /var/www/html/

RUN echo "www-data ALL=(ALL) NOPASSWD: /usr/bin/vim" >> /etc/sudoers

RUN echo '#!/bin/bash \n\
/bin/bash' > /usr/local/bin/backdoor.sh
RUN chmod 755 /usr/local/bin/backdoor.sh
RUN chown www-data:www-data /usr/local/bin/backdoor.sh

EXPOSE 80 22

CMD service apache2 start && service ssh start && tail -f /dev/null

