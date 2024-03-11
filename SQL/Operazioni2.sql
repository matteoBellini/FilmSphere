/*
Film(ID, Titolo, Descrizione, Durata, AnnoDiProduzione, Genere*, Recensioni, NumRecensioni, Critica, PremiFilm, PremiCineasta)
Genere(Nome)
Cineasta(IDCineasta, Nome, Cognome, DataNascita, LuogoNascita,)
Recitazione(IDCineasta*, Film*, NomePersonaggio)
Regia(IDCineasta*, Film*)
PremiCineasta(ID, Nome, Importanza, Categoria)
PremiFilm(ID, Nome, Importanza, Categoria)
Premiazione(IDCineasta*, IDPremio*, DataPremiazione)
Vincita(IDFilm*, IDPremio*, DataVincita)
Utente(CF, Nome, Cognome, DataNascita, Sesso, Mail, Password, Telefono, RinnovoAutomatico, TipoAbbonamento*)
Critico(CF, Nome, Cognome, DataNascita, Sesso, Azienda)
Recensione(CFUtente*, IDFilm*, Testo, Punteggio)
Critica(CFCritico*, IDFilm*, Testo, Punteggio)
Carta(Numero, CognomeTitolare, NomeTitolare, DataScadenza, CVV)
Preferenza(NumCarta*, CF*)
Fattura(Numero, DataEmissione, Importo, NumeroCarta*, Utente*)
Abbonamento(Tipo, Durata, Offline, NumeroDispositivi, RisoluzioneMassima, Prezzo)
Dispositivo(IndirizzoMac, Hardware, Risoluzione, IndirizzoIP, InizioConnessione, FineConnessione, Utente*, Paese*, Latitudine, Longitudine, ServerConnesso*)
Paese(Nome, NumeroAbitanti, IPRangeStart, IPRangeEnd)
Produzione(IDFilm*, Paese*)
Restrizione(ID, FormatoVideo, FormatoAudio)
PaeseResrizione(IDRestrizione*, Paese*)
Server(IndirizzoIP, Latitudine, Longitudine, CAPBanda, CAPTrasmissione, DimensioneCache, CaricoAttuale, Paese*)
P.o.P(IDFile*, IndirizzoIPServer*)
Visualizzazione(IDFile*, Dispositivo*, MinutoCorrente)
File(ID, Risoluzione, Bitrate, QualitàAudio, QualitàVideo, AspectRatio, DimensioneFile, LunghezzaVideo, FormatoVideo*, FormatoAudio*, Film*)
FormatoAudio(ID, MaxBitrate, Codec, Nome, DataRilascio)
FormatoVideo(ID, Nome, Codec, FPS, DataRilascio)
Lingua(NomeLingua)
Audio(IDFile*, Lingua*)
Sottotitolo(IDFile*, Lingua*)*/

-- Inserimento di un nuovo utente
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

-- Emissione Fattura
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

-- Sottoscrizione del relativo abbonamento
DROP PROCEDURE IF EXISTS scelta_abbonamento;
DELIMITER $$
CREATE PROCEDURE scelta_abbonamento(IN _abb VARCHAR(10), IN _CF VARCHAR(16), IN _NumCarta VARCHAR(16), OUT _check BOOL)
BEGIN
	DECLARE temp1 INTEGER DEFAULT 0;
    DECLARE temp2 INTEGER DEFAULT 0;
    DECLARE temp3 VARCHAR(10) DEFAULT NULL;
    DECLARE temp4 INTEGER DEFAULT 0;
    
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
    	UPDATE Utente U
        SET U.TipoAbbonamento = _abb
    	WHERE U.CF = _CF;
        SET _check = TRUE;
        CALL emissione_fattura(_CF, _abb, _numCarta);
    END IF;
END $$
DELIMITER ;

/*Individuazione del server migliore ad ogni nuova connessione (Latitudine e Longitudine memorizzate in radianti)*/
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
);

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
    DECLARE fetchServer VARCHAR(15) DEFAULT '';
    DECLARE fetchDistanza INTEGER DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT ED.IDEdgeServer, ED.Distanza
        FROM EDGE_SERVER ED
            INNER JOIN Server S
            ON S.IndirizzoIP = ED.IDEdgeServer
        WHERE IDServer = _Server AND S.CaricoAttuale < 90;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    OPEN cur;
    
    WHILE finito = 0 DO
        FETCH cur INTO (fetchServer, fetchDistanza);
        SET _ServerScelto = (SELECT IndirizzoIP
                             FROM Server S
                                INNER JOIN PoP P
                                ON S.IndirizzoIP = P.IndirizzoIPServer
                             WHERE IDFile = _File);
        IF _ServerScelto IS NOT NULL THEN 
            SET finito = 1;
        END IF;
    END WHILE;

    IF _ServerScelto IS NULL THEN 
        SET _ServerScelto = fetchServer;
        CALL CaricaFile(_ServerScelto, _File);
    CLOSE cur;

    SET _check = TRUE;
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




