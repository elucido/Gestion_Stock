DROP DATABASE IF EXISTS GESTION_POSTE;
CREATE DATABASE GESTION_POSTE CHARACTER SET 'utf8';
USE GESTION_POSTE;

CREATE TABLE STATUT (
	IdStatut INTEGER NOT NULL AUTO_INCREMENT,
	LibelleStatut VARCHAR(15) NOT NULL,
	
	CONSTRAINT PK_IDSTATUT PRIMARY KEY (IdStatut))
	ENGINE = InnoDB;
	

CREATE TABLE UTILISATEUR (
	IdUtil INTEGER NOT NULL AUTO_INCREMENT,
	IdentifiantUtil VARCHAR(15) NOT NULL,
	NomUtil VARCHAR(25) NOT NULL,
	PrenomUtil VARCHAR(25) NOT NULL,
	PrenomManage VARCHAR(15) NOT NULL,
	NomManage VARCHAR(15) NOT NULL,
	DateDebContrat DATE NOT NULL,
	DateFinContrat DATE,
	
	
	CONSTRAINT PK_IDUTIL PRIMARY KEY (IdUtil))
	ENGINE = InnoDB;

CREATE TABLE REMARQUE (
	IdRemarque INTEGER NOT NULL AUTO_INCREMENT,
	ContenuRemarque TEXT NOT NULL,
	DateRemarque DATE,
	Idutil INT NOT NULL,
	
	CONSTRAINT PK_IDREMARQUE PRIMARY KEY (IdRemarque))
	ENGINE = InnoDB;

CREATE TABLE STOCK (
	IdSTOCK INTEGER NOT NULL AUTO_INCREMENT,
	ModeleSTOCK VARCHAR(25) NOT NULL,
	NomSTOCK VARCHAR(15) NOT NULL,
	NumeroSerie VARCHAR(30) NOT NULL,
	IdStatut INTEGER DEFAULT 1 ,
	PretSTOCK  BOOLEAN DEFAULT 0, /*  Si la valeur de PretSTOCk est egal à 0 le pc est aux stock, s'il est egal à 1 le PC est preté	*/
	
	
	CONSTRAINT PK_IDSTOCK PRIMARY KEY (IdSTOCK),
	CONSTRAINT FK_IDSTATUT FOREIGN KEY (IdStatut) REFERENCES STATUT(IdStatut))
	
	ENGINE = InnoDB;
	

	
CREATE TABLE HISTORIQUE (
	IdHistorique INTEGER NOT NULL AUTO_INCREMENT,
	DateHistorique DATE,
	IdUtil INTEGER,
	IdSTOCK INTEGER,
	
	CONSTRAINT PK_IDHISTORIQUE PRIMARY KEY (IdHistorique),
	CONSTRAINT FK_IDUTIL2 FOREIGN KEY (IdUtil) REFERENCES UTILISATEUR(IdUtil),
	CONSTRAINT FK_IDSTOCK5 FOREIGN KEY (IdSTOCK) REFERENCES STOCK(IdSTOCK))
	ENGINE = InnoDB;

CREATE TABLE ATTRIBUE (
	IdSTOCK INTEGER,
	IdUtil INTEGER,
	DatePret DATE,
	
	CONSTRAINT PK_ATTRIBUE PRIMARY KEY (IdSTOCK, IdUtil),
	CONSTRAINT FK_IDSTOCK1 FOREIGN KEY (IdSTOCK) REFERENCES STOCK(IdSTOCK),
	CONSTRAINT FK_IDUTIL3 FOREIGN KEY (IdUtil) REFERENCES UTILISATEUR(IdUtil))
	ENGINE = InnoDB;
	
	
CREATE UNIQUE INDEX unique_stock ON STOCK (NomSTOCK);
CREATE UNIQUE INDEX unique_serie ON STOCK (NumeroSerie);

CREATE UNIQUE INDEX unique_util ON UTILISATEUR (NomUtil,PrenomUtil);
CREATE UNIQUE INDEX unique_id ON UTILISATEUR(IdentifiantUtil);


	
	
	
/* Le trigger permet de remplir la table historique au moment de la suppression d'une machine dans attribue*/	
DELIMITER |
CREATE TRIGGER archivage BEFORE DELETE
ON attribue
FOR EACH ROW
BEGIN
DECLARE date_jour DATE;
DECLARE	util INTEGER;
DECLARE STOCK INTEGER;

	SET date_jour = (SELECT DATE (NOW()));
	SET util = (SELECT IdUtil FROM attribue WHERE IdUtil = OLD.IdUtil);
	SET STOCK = (SELECT IdSTOCK FROM attribue WHERE IDSTOCK = OLD.IdSTOCK);
	
	INSERT INTO HISTORIQUE (DATEHISTORIQUE,IDUTIL,IDSTOCK) VALUES (date_jour, util, STOCK);

END |
DELIMITER ;

/* Ce trigger permet de passer la valeur de PretSTOCK dans Stock sur 1 pour indiquer que le pc est prété */
DELIMITER |
CREATE TRIGGER attribue BEFORE INSERT 
ON attribue 
FOR EACH ROW 
BEGIN 
DECLARE idMach INTEGER; 
SET idMach = (SELECT IdSTOCK FROM STOCK WHERE IDSTOCK = NEW.IdSTOCK); 
UPDATE STOCK SET PretSTOCK = 1 WHERE IdSTOCK = idMach;
END |
DELIMITER ;

/* Ce trigger permet de passer la valeur de PretSTOCK dans Stock sur 0 pour indiquer que le pc a été rendu */
DELIMITER |
CREATE TRIGGER retour AFTER DELETE 
ON attribue 
FOR EACH ROW 
BEGIN 
DECLARE idMach INTEGER; 
SET idMach = (SELECT IdSTOCK FROM STOCK WHERE IDSTOCK = OLD.IdSTOCK); 
UPDATE STOCK SET PretSTOCK = 0 WHERE IdSTOCK = idMach;
END |
DELIMITER ;


DELIMITER |
CREATE PROCEDURE newRemarque(IN texte TEXT)
BEGIN
DECLARE date_jour DATE;
SET date_jour = (SELECT DATE (NOW()));
INSERT INTO remarque (ContenuRemarque, DateRemarque) VALUES (texte, date_jour);
END|
DELIMITER ;


/* Cette procédure sert à attribuer un pc à un utilisateur*/
DELIMITER |

CREATE PROCEDURE ajoutAttribue(IN NomS VARCHAR(15), IN NomU VARCHAR(25))
BEGIN
DECLARE IdStocke INT;
DECLARE IdUtile INT;
DECLARE date_jour DATE;

	SET IdStocke = (SELECT IdSTOCK FROM STOCK WHERE NomSTOCK = NomS);
	SET IdUtile = NomU;
	SET date_jour = (SELECT DATE (NOW()));
	
	
	
	INSERT INTO attribue VALUES (IdStocke,IdUtile,date_jour);
END|

DELIMITER ;	


/* Cette procédure permet de créer un utilisateur*/
CREATE PROCEDURE addUtil (IN NomU VARCHAR(25), IN PrenomU VARCHAR(25))
INSERT INTO UTILISATEUR (NomUtil, PrenomUtil) VALUES (NomU, PrenomU);


/* Cette procédure supprime un pc dans la table attribue*/
DELIMITER |
CREATE PROCEDURE returnPC (IN Nom VARCHAR(15))
BEGIN
DECLARE NumStock INT;
	SET NumStock =(SELECT a.IdStock FROM attribue a, stock s WHERE s.IdStock = a.IdStock AND NomSTOCK = Nom);

	DELETE FROM attribue WHERE IdStock = NumStock;
END|
DELIMITER ;

 
	
INSERT INTO STATUT (LibelleStatut) VALUES ("En attente");
INSERT INTO STATUT (LibelleStatut) VALUES ("Disponible");
INSERT INTO STATUT (LibelleStatut) VALUES ("En préparation");
INSERT INTO STATUT (LibelleStatut) VALUES ("Attribué");

INSERT INTO UTILISATEUR (IdentifiantUtil, NomUtil, PrenomUtil,PrenomManage, NomManage, DateDebContrat, DateFinContrat) VALUES ("kellerh","KELLER","Herve","Jean-Francois","ROPITAL","2011-02-24",NULL);
INSERT INTO UTILISATEUR (IdentifiantUtil, NomUtil, PrenomUtil,PrenomManage, NomManage, DateDebContrat, DateFinContrat) VALUES ("pintora","PINTO","Rafael","Herve","KELLER","2011-02-24",NULL);
INSERT INTO UTILISATEUR (IdentifiantUtil, NomUtil, PrenomUtil,PrenomManage, NomManage, DateDebContrat, DateFinContrat) VALUES ("tas","TAS","Erdal","Herve","KELLER","2011-02-24",NULL);
INSERT INTO UTILISATEUR (IdentifiantUtil, NomUtil, PrenomUtil,PrenomManage, NomManage, DateDebContrat, DateFinContrat) VALUES ("1verniet","VERNIER","Thierry","Erdal","TAS","2017-10-13",NULL);
INSERT INTO UTILISATEUR (IdentifiantUtil, NomUtil, PrenomUtil,PrenomManage, NomManage, DateDebContrat, DateFinContrat) VALUES ("1bernier","BERNIER","Mathias","Erdal","TAS","2018-02-18","2018-10-30");
INSERT INTO UTILISATEUR (IdentifiantUtil, NomUtil, PrenomUtil,PrenomManage, NomManage, DateDebContrat, DateFinContrat) VALUES ("perrinad","PERRIN","Adrien","Erdal","TAS","2017-09-04","2019-09-30");

