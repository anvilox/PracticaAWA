#!/bin/bash

#######################################
# Script para instalar LAMP stack en ubuntu

# Se comprueba que el script se ejecuta como root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Fijamos la contraseña de root en MySQL
db_root_password="profesor"


# Actualizamos sistema
sudo apt-get update -y

## Instalamos Apache
sudo apt-get install apache2 apache2-doc apache2-mpm-prefork apache2-utils libexpat1 ssl-cert -y

## Instalamos PHP
sudo apt-get install php libapache2-mod-php php-mysql -y

# Instalamos MySQL database server
export DEBIAN_FRONTEND="noninteractive"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_root_password"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_root_password"

sudo apt-get install mysql-server -y

# Establecemos permisos para la carpeta de Apache
sudo chown -R www-data:www-data /var/www

# Reiniciamos Apache
sudo service apache2 restart

# Configuramos la base de datos

sudo mysql -u root -p$db_root_password <<EOF
create database articulos;
create user dbadmin identified by 'dbadmin';
grant all privileges on articulos.* to 'dbadmin';
use articulos;
create table libros (id INT(6) primary key, titulo varchar(30) not null, autor varchar(30) not null);
insert into libros values (1,'El Quijote','Cervantes');
insert into libros values (2,'La Divina Comedia','Dante');
insert into libros values (3,'El Lazarillo','Anonimo');
exit
EOF

#Crear index.php

cat > /var/www/html/index.php << ENDOFFILE
 <html>
 <head>
       <title>Libros</title>
 </head>
 <body>
       <h1>Lista de libros</h1>
       <table border="2">
               <tr>
                       <th>ID</th>
                       <th>Título</th>
                       <th>Autor</th>
               </tr>
<?php
$servername = "localhost";
$database = "articulos";
$username = "dbadmin";
$password = "dbadmin";
// Create connection
$conn = mysqli_connect($servername, $username, $password, $database);
// Check connection
if (!$conn) {
    die("Connection failed: " . mysqli_connect_error());
}
$sql = "SELECT id, titulo, autor FROM libros";
$result = mysqli_query($conn, $sql);

if (mysqli_num_rows($result) > 0) {
  // output data of each row
  while($row = mysqli_fetch_assoc($result)) {
        echo "<tr><td>".$row["id"]."</td><td>".$row["titulo"]."</td><td>".$row["autor"]."</td></tr>";
  }
  echo "</table>";
} else {
  echo "0 results";
}
mysqli_close($conn);
?>
</body>
</html>

 ENDOFFILE
