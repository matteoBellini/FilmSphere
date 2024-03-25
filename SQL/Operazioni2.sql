-- --------------------------------------
-- Inserimento di un nuovo utente
-- --------------------------------------
DROP PROCEDURE IF EXISTS registrazione_utente;
DELIMITER $$
CREATE PROCEDURE registrazione_utente(IN _CF VARCHAR(16),IN _Nome VARCHAR(20),IN _Cognome VARCHAR(20),IN _DataNascita DATE,IN _Sesso VARCHAR(1),IN _Mail VARCHAR(50),
                                      IN _Password VARCHAR(100),IN _Telefono VARCHAR(10),IN _RinnovoAutomatico BIT(1), IN _NumCarta VARCHAR(16), IN _cognTit VARCHAR(20), 
                                      IN _nomTit VARCHAR(20),IN _DataScad DATE, IN _cvv VARCHAR(3), OUT _check BOOL)
BEGIN 
	DECLARE temp1 INTEGER DEFAULT 0;
    DECLARE temp2 INTEGER DEFAULT 0;
    DECLARE temp3 INTEGER DEFAULT 0;
    
    SET temp1 = (SELECT COUNT(*)
                 FROM Utente
                 WHERE Mail = _Mail);
	SET temp2 = (SELECT COUNT(*)
                 FROM Utente
                 WHERE Telefono = _telefono);
    SET temp3 = (SELECT COUNT(*)
                 FROM Carta
                 WHERE Numero = _NumCarta);
    
    IF temp1 > 0 OR temp2 > 0 OR _mail NOT LIKE '%@%.%' THEN
    	SET _check = FALSE;
    ELSE
    	IF temp3 = 0 THEN
        	INSERT INTO Carta
            VALUES(_NumCarta, _cognTit, _nomeTit, _DataScad, _cvv);
        END IF;
        INSERT INTO Preferenza
            VALUES(_NumCarta, _CF);
    	INSERT INTO Utente(CF, Nome, Cognome, DataNascita, Sesso, Mail, Password, Telefono, RinnovoAutomatico)
        VALUES(_CF, _Nome, _Cognome, _DataNascita, _Sesso, _Mail, _Password, _Telefono, _RinnovoAutomatico);
        SET _check = TRUE;
    END IF;
    
END $$
DELIMITER ;

-- --------------------------------------
-- Emissione Fattura
-- --------------------------------------
DROP PROCEDURE IF EXISTS emissione_fattura;
DELIMITER $$
CREATE PROCEDURE emissione_fattura(IN _utente VARCHAR(16), IN _abb VARCHAR(10), IN _NumCarta)
BEGIN
	DECLARE _importo DOUBLE DEFAULT 0;
    
    SET _importo = (SELECT Prezzo
                    FROM Abbonamento
                    WHERE Tipo = _abb);
	
    INSERT INTO Fattura(DataEmissione, Importo, NumeroCarta, Utente)
    VALUES (CURRENT_DATE, _importo, _NumCarta, _utente);
END $$
DELIMITER ;

-- --------------------------------------
-- Sottoscrizione del relativo abbonamento
-- --------------------------------------
DROP PROCEDURE IF EXISTS scelta_abbonamento;
DELIMITER $$
CREATE PROCEDURE scelta_abbonamento(IN _abb VARCHAR(10), IN _CF VARCHAR(16), IN _NumCarta VARCHAR(16), OUT _check BOOL)
BEGIN
	DECLARE temp1 INTEGER DEFAULT 0;
    DECLARE temp2 INTEGER DEFAULT 0;
    DECLARE temp3 VARCHAR(10) DEFAULT NULL;
    DECLARE temp4 INTEGER DEFAULT 0;
    DECLARE durataAbbonamento INTEGER DEFAULT 0;
    
    SET temp1 = (SELECT COUNT(*)
                 FROM Abbonamento
                 WHERE Tipo = _abb);
	SET temp2 = (SELECT COUNT(*)
                 FROM Utente
                 WHERE CF = _CF);
	SET temp3 = (SELECT TipoAbbonamento
                 FROM Utente
                 WHERE CF = _CF);
    SET temp4 = (SELECT COUNT(*)
                 FROM Carta
                 WHERE Numero = _NumCarta);
    
    IF temp1 = 0 OR temp2 = 0 OR temp3 IS NULL OR temp4 = 0 THEN
    	SET _check = FALSE;
	ELSE
        SET durataAbbonamento = (SELECT Durata
                                 FROM Abbonamento
                                 WHERE Tipo = _abb)

    	UPDATE Utente U
        SET U.TipoAbbonamento = _abb , U.DataScadenza = CURRENT_DATE + INTERVAL durataAbbonamento DAY
    	WHERE U.CF = _CF;

        SET _check = TRUE;
        CALL emissione_fattura(_CF, _abb, _numCarta);
    END IF;
END $$
DELIMITER ;

-- --------------------------------------
-- Individuazione del server migliore ad ogni nuova connessione (Latitudine e Longitudine memorizzate in radianti)
-- --------------------------------------
DROP PROCEDURE IF EXISTS find_best_server;
DELIMITER $$
CREATE PROCEDURE find_best_server(IN Dispositivo VARCHAR(17), IN Latitudine FLOAT, IN Longitudine FLOAT, IN targetFile INTEGER, OUT resultServer VARCHAR(15), OUT _check BOOL)
BEGIN 
	DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchServer VARCHAR(15) DEFAULT '';
    DECLARE fetchLat FLOAT DEFAULT 0;
    DECLARE fetchLong FLOAT DEFAULT 0;
    DECLARE fetchCarico FLOAT DEFAULT 0;
    DECLARE distanza FLOAT DEFAULT 0;
    DECLARE distanzaMin FLOAT DEFAULT 100000;
    
    DECLARE cur CURSOR FOR
    	SELECT S.IndirizzoIP, S.Latitudine, S.Longitudine, S.CaricoAttuale
        FROM Server S
        	INNER JOIN PoP P
            ON P.IPServer = S.IndirizzoIP;
        WHERE IDFile = targetFile;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    SET _check = FALSE;
    
    OPEN cur;
    
    WHILE finito = 0 DO
    	FETCH cur INTO (fetchServer, fetchLat, fetchLong, fetchCarico);
        SET distanza = ACOS(
			(COS(Latitudine) * COS(Longitudine) * COS(fetchLat) * COS(fetchLong)) +
			(COS(Latitudine) * SIN(Longitudine) * COS(fetchLat) * SIN(fetchLong)) +
			(SIN(Latitudine) * SIN(fetchLat))
		) * 6371;
        
        IF fetchCarico < 90 THEN	
        	IF distanza < distanzaMin THEN
        		SET distanzaMin = distanza;
            	SET resultServer = fetchServer;
            END IF;
        END IF;
    END WHILE;
    
    SET _check = TRUE;
    CLOSE cur;
    
    IF distanzaMin > 1500 THEN
    	CALL CaricaFile(_ServerScelto, _File);
    END IF;
END $$
DELIMITER ;

/*DISTANZA COORDINATE: distanza = √((6371 * cos(lat₁) * Δlon)² + (6371 * Δlat)²) (Latitudine e Longitudine memorizzate in radianti)*/
DROP TABLE IF EXISTS EDGE_SERVER;
DELIMITER $$
CREATE TABLE EDGE_SERVER(
	IDServer VARCHAR(15) NOT NULL,
  	IDEdgeServer VARCHAR(15) NOT NULL,
  	Distanza INTEGER NOT NULL,
  	PRIMARY KEY (IDServer, IDEdgeServer)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

DROP PROCEDURE IF EXISTS BUILD_EDGE_SERVER$$
CREATE PROCEDURE BUILD_EDGE_SERVER (OUT _check BOOL)
BEGIN
	DECLARE finito INTEGER DEFAULT 0;
	DECLARE IpServer VARCHAR(15) DEFAULT '';
    DECLARE Latitudine FLOAT DEFAULT 0;
    DECLARE Longitudine FLOAT DEFAULT 0;
    DECLARE cur CURSOR FOR
    	SELECT IndirizzoIP, Latitudine, Longitudine
    	FROM Server;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    SET _check = FALSE;
    
    OPEN cur;
    
    WHILE finito = 0 DO
    	FETCH cur INTO (IpServer, Latitudine, Longitudine);
		CALL ADD_EDGE_SERVER(IpServer, Latitudine, Longitudine);
    END WHILE;
    
    SET _check = TRUE;
    
    CLOSE cur;
	
END $$

DROP PROCEDURE IF EXISTS ADD_EDGE_SERVER$$
CREATE PROCEDURE ADD_EDGE_SERVER(IN IpServer VARCHAR(15), IN Latitudine FLOAT, IN Longitudine FLOAT, OUT _check BOOL)
BEGIN
	DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchServer VARCHAR(15) DEFAULT '';
    DECLARE fetchLat FLOAT DEFAULT 0;
    DECLARE fetchLong FLOAT DEFAULT 0;
    DECLARE distanza FLOAT DEFAULT 0;
    DECLARE cur CURSOR FOR
    	SELECT IndirizzoIP, Latitudine, Longitudine
    	FROM Server
        WHERE IndirizzoIP <> IpServer;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPEN cur;
    
    WHILE finito = 0 DO
    	FETCH cur INTO (fetchServer, fetchLat, fetchLong);
        
        SET distanza = ACOS(
			(COS(Latitudine) * COS(Longitudine) * COS(fetchLat) * COS(fetchLong)) +
			(COS(Latitudine) * SIN(Longitudine) * COS(fetchLat) * SIN(fetchLong)) +
			(SIN(Latitudine) * SIN(fetchLat))
			) * 6371;
            
        IF distanza < 1000 THEN
        	INSERT INTO EDGE_SERVER VALUES (IpServer, fetchServer, distanza);
        END IF;
    END WHILE;

    CLOSE cur;
END $$
DELIMITER ;

-- Ipotizziamo che i server vengano posti ad una distanza adeguata da permette ad ogni server di avere almeno 1 edge server.
DROP PROCEDURE IF EXISTS Find_Edge_Server;
DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS Find_Edge_Server(IN _Server VARCHAR(15), IN _File INTEGER, OUT _ServerScelto VARCHAR(15), OUT _check BOOL)
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchServer VARCHAR(15) DEFAULT NULL;
    DECLARE fetchDistanza INTEGER DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT ED.IDEdgeServer, ED.Distanza
        FROM EDGE_SERVER ED
            INNER JOIN Server S
            ON S.IndirizzoIP = ED.IDEdgeServer
        WHERE IDServer = _Server AND S.CaricoAttuale < 90
        ORDER BY ED.Distanza;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    OPEN cur;
    
    WHILE finito = 0 DO
        FETCH cur INTO (fetchServer, fetchDistanza);
        SET _ServerScelto = (SELECT S.IndirizzoIP
                             FROM Server S
                                INNER JOIN PoP P
                                ON S.IndirizzoIP = P.IndirizzoIPServer
                             WHERE P.IDFile = _File AND S.IndirizzoIP = fetchServer);
        IF _ServerScelto IS NOT NULL THEN 
            SET finito = 1;
        END IF;
    END WHILE;

    IF _ServerScelto IS NULL THEN
        CALL Find_Edge_Server_Free_Cache(_Server, _File, _ServerScelto);
        CALL CaricaFile(_ServerScelto, _File);
    CLOSE cur;

    SET _check = TRUE;
END $$
DELIMITER ;

-- Trova un Edge Server con spazio a sufficenza in cache per memorizzare il film in ingresso
DROP PROCEDURE IF EXISTS Find_Edge_Server_Free_Cache;
DELIMITER $$
CREATE PROCEDURE Find_Edge_Server_Free_Cache(IN _Server VARCHAR(15), IN _File INTEGER, OUT _resultServer VARCHAR(15))
BEGIN
    DECLARE finito INTEGER DEFUALT 0;
    DECLARE fetchServer VARCHAR(15) DEFAULT '';
    DECLARE fetchDistanza INTEGER DEFAULT 0;
    DECLARE spazioOccupato INTEGER DEFAULT 0;
    DECLARE _dimensioneCache INTEGER DEFAULT 0;
    DECLARE dimensioneFilm INTEGER DEFAULT 0;
    
    DECLARE cur CURSOR FOR
        SELECT ED.IDEdgeServer, ED.Distanza
        FROM EDGE_SERVER ED
            INNER JOIN Server S
            ON S.IndirizzoIP = ED.IDEdgeServer
        WHERE IDServer = _Server AND S.CaricoAttuale < 90
        ORDER BY ED.Distanza;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    SET dimensioneFilm = (SELECT DimensioneFile
                          FROM File
                          WHERE ID = _File);

    OPEN cur;

    WHILE finito = 0 DO
        FETCH cur INTO (fetchServer, fetchDistanza);
        SET _dimensioneCache = (SELECT DimensioneCache
                                FROM Server
                                WHERE IndirizzoIP = fetchServer);

        SET spazioOccupato = (SELECT SUM(DimensioneFile)
                              FROM PoP P
                                  INNER JOIN File F
                                  ON F.ID = P.IDFile
                              WHERE P.IPServer = fetchServer);
        
        IF spazioOccupato + dimensioneFilm <= DimensioneCache THEN
            SET _resultServer = fetchServer;
            SET finito = 1;
        END IF;
    END WHILE;
    
    CLOSE cur;
END $$
DELIMITER ;

-- Aggiunta di un file all'interno di un Server (Si aggiunge il file alla relazione POP)
DROP PROCEDURE IF EXISTS CaricaFile;
DELIMITER $$
CREATE PROCEDURE CaricaFile (IN _Server VARCHAR(15), IN _file INTEGER, OUT _check BOOL)
BEGIN
    INSERT INTO PoP VALUES (_file, _Server);
    SET _check = TRUE;
END $$
DELIMITER ;

-- --------------------------------------
-- Individuazione dei film che un utente può vedere in un certo paese (non sottoposti a restrizioni)
-- --------------------------------------
DROP PROCEDURE IF EXISTS VerificaRestrizioni;
DELIMITER $$
CREATE PROCEDURE VerificaRestrizioni(IN _IndirizzoMAC VARCHAR(17), IN _Utente VARCHAR(16), IN _Paese VARCHAR(20), IN _Film INTEGER, OUT _IDFile INTEGER)
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE _RisoluzioneMassima INTEGER DEFAULT 0;
    DECLARE fetchID INTEGER DEFAULT 0;
    DECLARE fetchRisoluzione INTEGER DEFAULT 0;
    DECLARE fetchAudio VARCHAR(5) DEFAULT '';
    DECLARE fetchVideo VARCHAR(5) DEFAULT '';
    
    DECLARE cur CURSOR FOR
        WITH RestrPaese AS
        (SELECT R.FormatoVideo, R.FormatoAudio
        FROM PaeseRestrizione PR
            INNER JOIN Restrizione R
            ON PR.IDRestrizione = R.ID
        WHERE PR.Paese = _Paese)
        SELECT F.ID, F.Risoluzione, R.FormatoVideo, R.FormatoAudio
        FROM File F
            LEFT OUTER JOIN RestrPaese R
            ON F.FormatoAudio = R.FormatoAudio OR F.FormatoVideo = R.FormatoVideo
        WHERE F.Film = _Film
        ORDER BY F.Risoluzione DESC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    SET _RisoluzioneMassima = (SELECT A.RisoluzioneMassima
                               FROM Utente U
                                    INNER JOIN Abbonamento A 
                                    ON U.TipoAbbonamento = A.Tipo
                               WHERE U.CF = _Utente);
    
    OPEN cur;
    
    WHILE finito = 0 DO
        FETCH cur INTO (fetchID, fetchRisoluzione, fetchAudio, fetchVideo);
        IF fetchRisoluzione <= _RisoluzioneMassima THEN
            IF fetchAudio IS NULL AND fetchVideo IS NULL THEN
                SET _IDFile = fetchID;
                SET finito = 1;
            END IF;
        END IF;
    END WHILE;

    CLOSE cur;
END $$
DELIMITER ;

-- --------------------------------------
-- Inserimento di nuovi dispositivi associati ad un utente, in linea con le specifiche del proprio abbonamento
-- --------------------------------------
DROP TRIGGER IF EXISTS InserimentoDispositivo;
DELIMITER $$
CREATE TRIGGER InserimentoDispositivo BEFORE INSERT ON Dispositivo
FOR EACH ROW
BEGIN

    DECLARE maxDispositiviON INTEGER DEFAULT 0;
    DECLARE numDispositiviON INTEGER DEFAULT 0;

    SET maxDispositiviON = (SELECT NumeroDispositivi
                            FROM Utente U
                                INNER JOIN Abbonamento A
                                ON A.Tipo = U.TipoAbbonamento
                            WHERE U.CF = NEW.Utente);

    SET numDispositiviON = (SELECT COUNT(*)
                            FROM Dispositivo D
                            WHERE D.Utente = NEW.Utente AND D.FineConnessione IS NULL);

    IF numDispositiviON = maxDispositiviON THEN
        SIGNAL SQL STATE '45000'
        SET MESSAGE_TEXT = "Hai raggiunto il numero massimo di dispositivi connessi contemporaneamente.";
    END IF;

END $$
DELIMITER ;

-- --------------------------------------
-- Invio di una notifica il giorno precedente della scadenza dell'abbonamento
-- --------------------------------------
CREATE TABLE UtentiInScadenza(
    Utente VARCHAR(16) NOT NULL PRIMARY KEY
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

DROP PROCEDURE IF EXISTS build_utenti_scadenza;
DELIMITER $$
CREATE PROCEDURE build_utenti_scadenza()
BEGIN
    TRUNCATE UtentiInScadenza;

    INSERT INTO UtentiInScadenza
    SELECT CF
    FROM Utente 
    WHERE DATEDIFF(CURRENT_DATE, DataScadenza) = 1 AND RinnovoAutomatico = 0;
    
END $$
DELIMITER ;

DROP EVENT IF EXISTS invioNotificaScadenza;
CREATE EVENT invioNotificaScadenza ON SCHEDULE EVERY 1 DAY
DO 
    CALL build_utenti_scadenza();

-- --------------------------------------
-- Rating di un film
-- --------------------------------------
-- Trigger relativo alle critiche
DROP TRIGGER IF EXISTS rating_critiche;
DELIMITER $$
CREATE TRIGGER rating_critiche AFTER INSERT ON Critica
FOR EACH ROW
BEGIN
    DECLARE punteggioCritica INTEGER DEFAULT 0;
    DECLARE numCritiche INTEGER DEFAULT 0;

    SELECT SUM(Punteggio) as s, COUNT(*) as n INTO punteggioCritica, numCritiche
    FROM Critica
    WHERE IDFilm = NEW.IDFilm;

    UPDATE Film
    SET Critica = punteggioCritica / numCritiche
    WHERE ID = NEW.IDFilm;
END $$
DELIMITER ;

-- Trigger relativo alle recensioni
DROP TRIGGER IF EXISTS rating_recensioni;
DELIMITER $$
CREATE TRIGGER rating_recensioni AFTER INSERT ON Recensione
FOR EACH ROW
BEGIN
    DECLARE punteggioRecensioni INTEGER DEFAULT 0;
    DECLARE numeroRecensioni INTEGER DEFAULT 0;

    SELECT Recensioni, NumRecensioni INTO punteggioRecensioni, numeroRecensioni
    FROM Film
    WHERE ID = NEW.IDFilm;

    UPDATE Film
    SET Recensioni = ((punteggioRecensioni * numeroRecensioni) + NEW.Punteggio) / (numeroRecensioni + 1),
        NumRecensioni = numeroRecensioni + 1
    WHERE ID = NEW.IDFilm;
END $$
DELIMITER ;

-- Trigger relativo ai premi di un film
DROP TRIGGER IF EXISTS rating_premi_film;
DELIMITER $$
CREATE TRIGGER rating_premi_film AFTER INSERT ON Vincita
FOR EACH ROW
BEGIN
    DECLARE punteggioPremi INTEGER DEFAULT 0;
    DECLARE numeroPremi INTEGER DEFAULT 0;

    SELECT SUM(P.Importanza) as s, COUNT(*) as numPremi INTO punteggioPremi, numeroPremi
    FROM Vincita V
        INNER JOIN PremiFilm P
        ON V.IDPremio = P.ID
    WHERE V.IDFilm = NEW.IDFilm;

    UPDATE Film
    SET PremiFilm = punteggioPremi / numeroPremi
    WHERE ID = NEW.IDFilm;
END $$
DELIMITER ;

-- Trigger relativo ai premi di un cineasta
DROP TRIGGER IF EXISTS rating_premi_cineasta;
DELIMITER $$
CREATE TRIGGER rating_premi_cineasta AFTER INSERT ON Premiazione
FOR EACH ROW
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchFilm INTEGER DEFAULT 0;
    DECLARE ratingRecitazione INTEGER DEFAULT 0;
    DECLARE numeroPremiRecitazione INTEGER DEFAULT 0;
    DECLARE ratingRegia INTEGER DEFAULT 0;
    DECLARE numeroPremiRegia INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT Film
        FROM Recitazione
        WHERE IdCineasta = NEW.IdCineasta;

    DECLARE HANDLER FOR NOT FOUND SET finito = 1;

    OPEN cur1;

    WHILE finito = 0 DO
        FETCH cur INTO (fetchFilm);

        SELECT SUM(PC.Importanza) AS SommaImportanzaPremi, COUNT(*) AS nPremi INTO ratingRecitazione, numeroPremiRecitazione
        FROM Recitazione R
            INNER JOIN Premiazione P
            ON R.IdCineasta = P.IdCineasta
            INNER JOIN PremiCineasta PC
            ON P.IdPremio = PC.ID
        WHERE R.Film = fetchFilm;

        SELECT SUM() AS SommaImportanzaPremi2, COUNT(*) AS nPremi2 INTO ratingRegia, numeroPremiRegia
        FROM Regia R
            INNER JOIN Premiazione P
            ON R.IdCineasta = P.IdCineasta
            INNER JOIN PremiCineasta PC
            ON P.IdPremio = PC.ID
        WHERE R.Film = fetchFilm;

        UPDATE Film
        SET PremiCineasta = (ratingRecitazione + ratingRegia) / (numeroPremiRecitazione + numeroPremiRegia)
        WHERE ID = fetchFilm;
    END WHILE;

    CLOSE cur1;
END $$
DELIMITER ;

-- Procedure che restituisce il Rating di un film in ingresso
DROP PROCEDURE IF EXISTS ratingFilm;
DELIMITER $$
CREATE PROCEDURE ratingFilm(IN _film INTEGER, OUT _rating DOUBLE)
BEGIN
    DECLARE ratingRecensioni INTEGER DEFAULT 0;
    DECLARE ratingCritica INTEGER DEFAULT 0;
    DECLARE ratingPremiFilm INTEGER DEFAULT 0;
    DECLARE ratingPremiCineasta INTEGER DEFAULT 0;

    SELECT Recensioni, Critica, PremiFilm, PremiCineasta INTO ratingRecensioni, ratingCritica, ratingPremiFilm, ratingPremiCineasta
    FROM Film
    WHERE ID = _film;

    SET _rating = (0.2 * ratingRecensioni) + (0.4 * ratingCritica) + (0.4 * ((0.6 * ratingPremiFilm) + (0.4 * ratingPremiCineasta)));
END $$
DELIMITER ;

-- --------------------------------------
-- Caching
-- --------------------------------------
DROP PROCEDURE IF EXISTS Caching;
DELIMITER $$
CREATE PROCEDURE Caching (IN _Dispositivo VARCHAR(17))
BEGIN
    DECLARE _Paese VARCHAR(20) DEFAULT '';
    DECLARE _Abbonamento VARCHAR(10) DEFAULT '';
    DECLARE GenerePreferito VARCHAR(25) DEFAULT '';

    SET GenerePreferito = (WITH NumV AS(
                            SELECT F2.Genere, COUNT(*) AS NumeroVisualizzazioni
                            FROM Visualizzazione V
                                INNER JOIN File F
                                ON F.ID = V.IDFile
                                INNER JOIN Film F2
                                ON F2.ID = F.ID 
                            WHERE V.Dispositivo = _Dispositivo
                            GROUP BY F2.Genere
                            ORDER BY NumeroVisualizzazioni
                            LIMIT 1
                            )
                            SELECT Genere
                            FROM NumV
                            );

    SET _Paese = (SELECT Paese
                  FROM Dispositivo
                  WHERE IndirizzoMAC = _Dispositivo);

    SET _Abbonamento = (SELECT U.TipoAbbonamento
                        FROM Dispositivo D
                            INNER JOIN Utente U
                            ON D.Utente = U.CF
                        WHERE D.IndirizzoMac = _Dispositivo);
    
    SELECT C.IDFile, C.IDFilm, C.Titolo
    FROM Classifica C
        LEFT OUTER JOIN Visualizzazione V
        ON V.IDFile = C.IDFile
        INNER JOIN Film F
        ON F.ID = C.IDFilm
    WHERE V.Dispositivo = _Dispositivo AND C.Paese = _Paese
        AND C.Abbonamento = _Abbonamento AND GenerePreferito = F.Genere
    ORDER BY C.TotaleVisualizzazioni DESC
    LIMIT 2;
END $$
DELIMITER ;