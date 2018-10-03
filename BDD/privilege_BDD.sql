-- A executer en local directement sur le server Mysql

mysql
CREATE USER '7Bavansi'@'localhost' IDENTIFIED BY '2017B@v@n$';
CREATE USER 'MySQLAdmin'@'localhost' IDENTIFIED BY 'SQL$rv2017';

GRANT ALL PRIVILEGES ON *.* TO 'MySQLAdmin'@'localhost';
GRANT SELECT ON gestion_poste.* TO '7Bavansi'@'localhost';
GRANT CREATE,DELETE ON gestion_poste.attribue TO '7Bavansi'@'localhost';
GRANT CREATE,UPDATE ON gestion_poste.stock TO '7Bavansi'@'localhost';

