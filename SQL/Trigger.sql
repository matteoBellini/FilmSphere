-- Controllo dell'inserimento o modifica dell'anno di produzione di ogni film
DROP TRIGGER IF EXISTS Tfilm;
DELIMITER $$
CREATE TRIGGER TFilm BEFORE INSERT OR UPDATE ON Film
FOR EACH ROW
BEGIN
    IF YEAR(NEW.AnnoDiProduzione) > YEAR(CURRENT_DATE) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento con Anno di Produzion non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo del corretto inserimento dei dati di un cineasta
DROP TRIGGER IF EXISTS TCineasta;
DELIMITER $$
CREATE TRIGGER TCineasta BEFORE INSERT OR UPDATE ON Cineasta
FOR EACH ROW
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE NomePaese VARCHAR(20) DEFAULT '';

    SET NomePaese = (SELECT Nome
                     FROM Paese
                     WHERE Nome = NEW.LuogoNascita);
    
    IF NomePaese <> NEW.LuogoNascita THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento con luogo di nascita non valido";
    END IF;
    
    IF NEW.DataNascita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento con Anno di Nascita non valido";
    END IF;
    
END $$
DELIMITER ;

-- Controllo che i dati di una premiazione siano corretti
DROP TRIGGER IF EXISTS TPremiazione;
DELIMITER $$
CREATE TRIGGER TPremiazione BEFORE INSERT OR UPDATE ON Premiazione
FOR EACH ROW
BEGIN
    IF NEW.DataPremiazione > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data premiazione non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo che i dati di una vincita siano corretti
DROP TRIGGER IF EXISTS TVincita;
DELIMITER $$
CREATE TRIGGER TVincita BEFORE INSERT OR UPDATE ON Vincita
FOR EACH ROW
BEGIN
    IF NEW.DataVincita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data vincita non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo che i dati di un utente siano corretti
DROP TRIGGER IF EXISTS TUtente;
DELIMITER $$
CREATE TRIGGER TUtente BEFORE INSERT OR UPDATE ON Utente
FOR EACH ROW
BEGIN
    IF NEW.DataNascita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data Nascita non valido";
    END IF;

    IF NEW.Sesso <> 'M' OR NEW.Sesso <> 'F' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Sesso non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo che i dati di un critico siano corretti
DROP TRIGGER IF EXISTS TCritico;
DELIMITER $$
CREATE TRIGGER TCritico BEFORE INSERT OR UPDATE ON Critico
FOR EACH ROW
BEGIN
    IF NEW.DataNascita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data Nascita non valido";
    END IF;

    IF NEW.Sesso <> 'M' OR NEW.Sesso <> 'F' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Sesso non valido";
    END IF;
END $$
DELIMITER ;

-- Business Rule per la definizione intervallo accettabile di punteggio per una recensione
DROP TRIGGER IF EXISTS TRecensione;
DELIMITER $$
CREATE TRIGGER TRecensione BEFORE INSERT OR UPDATE ON Recensione
FOR EACH ROW
BEGIN
    IF NEW.Punteggio > 10 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di un punteggio non valido";
    END IF;
END $$
DELIMITER ;

-- Business Rule per la definizione intervallo accettabile di punteggio per una critica
DROP TRIGGER IF EXISTS TCritica;
DELIMITER $$
CREATE TRIGGER TCritica BEFORE INSERT OR UPDATE ON Critica
FOR EACH ROW
BEGIN
    IF NEW.Punteggio > 10 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di un punteggio non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo che la data di scadenza della carta si valida
DROP TRIGGER IF EXISTS TCarta;
DELIMITER $$
CREATE TRIGGER TCarta BEFORE INSERT ON Carta
FOR EACH ROW
BEGIN
    IF NEW.DataScadenza < CURRENT_DATE THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di una carta scaduta";
    END IF;
END $$
DELIMITER ;

-- Controllo che la risoluzionne di un dispositivo sia corretta
DROP TRIGGER IF EXISTS TDispositivo;
DELIMITER $$
CREATE TRIGGER TDispositivo BEFORE INSERT ON Dispositivo
FOR EACH ROW
BEGIN
    IF NEW.Risoluzione NOT IN ("720", "1080", "1440", "2160") THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di una risoluzione non valida";
    END IF;
END $$
DELIMITER ;

-- Controllo che la data di rilascio di un Formato Audio sia corretta
DROP TRIGGER IF EXISTS TFormatoAudio;
DELIMITER $$
CREATE TRIGGER TFormatoAudio BEFORE INSERT OR UPDATE ON FormatoAudio
FOR EACH ROW
BEGIN
    IF NEW.DataRilascio > CURRENT_DATE THEN
        SIGNAL SQL STATE '45000'
        SET MESSAGE_TEXT = "Inseriemento di una Data di Rilascio non valida";
    END IF;
END $$
DELIMITER ;


-- Controllo che la data di rilascio di un Formato Video sia corretta
DROP TRIGGER IF EXISTS TFormatoVideo;
DELIMITER $$
CREATE TRIGGER TFormatoVideo BEFORE INSERT OR UPDATE ON FormatoVideo
FOR EACH ROW
BEGIN
    IF NEW.DataRilascio > CURRENT_DATE THEN
        SIGNAL SQL STATE '45000'
        SET MESSAGE_TEXT = "Inseriemento di una Data di Rilascio non valida";
    END IF;
END $$
DELIMITER ;

-- Aggiunta del carico di un server nel momento in cui inizia una visualizzazione
DROP TRIGGER IF EXISTS AddCarico
DELIMITER $$
CREATE TRIGGER AddCarico AFTER INSERT OR UPDATE ON Visualizzazione
FOR EACH ROW
BEGIN
    DECLARE carico FLOAT DEFAULT 0;
    DECLARE risoluzione INTEGER DEFAULT 0;
    DECLARE bitrate INTEGER DEFAULT 0;
    DECLARE _server VARCHAR(15) DEFAULT '';
    DECLARE _caricoServer INTEGER DEFAULT 0;

    SET risoluzione = (SELECT Risoluzione
                       FROM File
                       WHERE ID = NEW.IDFile);

    SET bitrate = (SELECT Bitrate
                   FROM File
                   WHERE ID = NEW.IDFile);

    SET _server = (SELECT ServerConnesso
                   FROM Dispositivo
                   WHERE IndirizzoMac = NEW.Dispositivo);

    SET _caricoServer = (SELECT CaricoAttuale
                         FROM Server
                         WHERE IndirizzoIP = NEW.IndirizzoIP);

    SET carico = (risoluzione / 20 + bitrate / 100) / 600;

    IF _caricoServer + carico > 90 THEN
        CALL Find_Edge_Server(_server, NEW.IDFile);
    ELSE
        UPDATE Server
        SET CaricoAttuale = CaricoAttuale + carico;
        WHERE IndirizzoIP = _server;
    END IF;
END $$
DELIMITER ;

-- Rimozione del carico da un server nel momento in cui una connessione termina
DROP TRIGGER IF EXISTS SubCarico;
DELIMITER $$
CREATE TRIGGER SubCarico AFTER UPDATE ON Dispositivo
BEGIN
    DECLARE _file INTEGER DEFAULT 0;
    DECLARE risoluzione INTEGER DEFAULT 0;
    DECLARE bitrate INTEGER DEFAULT 0;
    DECLARE carico FLOAT DEFAULT 0;

    IF NEW.FineConnessione IS NOT NULL THEN
        SET _file = (SELECT IDFile
                     FROM Visualizzazione
                     WHERE Dispositivo = NEW.IndirizzoMAC
                     ORDER BY InizioConnessione DESC
                     LIMIT 1);
        SET risoluzione = (SELECT Risoluzione
                           FROM File
                           WHERE ID = _file);

        SET bitrate = (SELECT Bitrate
                       FROM File
                       WHERE ID = _file);

        SET carico = (risoluzione / 20 + bitrate / 100) / 600;

        UPDATE Server
        SET CaricoAttuale = CaricoAttuale - carico;
        WHERE IndirizzoIP = NEW.Server;
    END IF;
END $$
DELIMITER ;