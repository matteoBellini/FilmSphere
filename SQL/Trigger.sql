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
    IF NEW.Risoluzione NOT IN ("720p", "1080p", "1440p", "2160p") THEN
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