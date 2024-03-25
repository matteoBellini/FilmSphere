DROP TABLE IF EXISTS log_classifiche;
CREATE TABLE log_classifiche (
    IDFile INTEGER NOT NULL,
    Abbonamento VARCHAR(10) NOT NULL,
    Paese VARCHAR(20) NOT NULL,
    DataVisualizzazione DATETIME NOT NULL,

    PRIMARY KEY(IDFile, Abbonamento, Paese, DataVisualizzazione)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS Classifica;
CREATE TABLE Classifica (
    IDFile INTEGER NOT NULL,
    IDFilm INTEGER NOT NULL,
    Titolo VARCHAR(255) NOT NULL,
    Paese VARCHAR(20) NOT NULL,
    Abbonamento VARCHAR(10) NOT NULL,
    TotaleVisualizzazioni INTEGER NOT NULL,

    PRIMARY KEY(IDFile, Paese, Abbonamento)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

-- Trigger di push
DROP TRIGGER IF EXISTS push_log_classifiche;
DELIMITER $$
CREATE TRIGGER push_log_classifiche AFTER INSERT ON Visualizzazione
BEGIN
    DECLARE _abbonamento VARCHAR(10) DEFAULT '';
    DECLARE _paese VARCHAR(20) DEFAULT '';
    
    SET _abbonamento = (SELECT U.TipoAbbonamento
                        FROM Dispositivo D
                            INNER JOIN Utente U
                            ON U.CF = D.Utente
                        WHERE D.IndirizzoMac = NEW.Dispositivo)

    SET _paese = (SELECT Paese
                  FROM Dispositivo
                  WHERE IndirizzoMac = NEW.Dispositivo);

    INSERT INTO log_classifiche VALUES(NEW.IDFile, _abbonamento, _paese, NEW.InizioVisualizzazione);
END $$
DELIMITER ;

-- incremental refresh in modalità completa
DROP PROCEDURE IF EXISTS refresh_classifiche;
DELIMITER $$
CREATE PROCEDURE refresh_classifiche()
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchFile INTEGER DEFAULT 0;
    DECLARE fetchFilm INTEGER DEFAULT 0;
    DECLARE fetchTitolo VARCHAR(255) DEFAULT '';
    DECLARE fetchPaese VARCHAR(20) DEFAULT '';
    DECLARE fetchAbbonamento VARCHAR(10) DEFAULT '';
    DECLARE presenza INTEGER DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT LC.IDFile, F1.Film, F2.Titolo, LC.Paese, LC.Abbonamento
        FROM log_classifiche LC
            INNER JOIN File F1
            ON F1.ID = LC.IDFile
            INNER JOIN Film F2
            ON F2.ID = F1.Film;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    OPER cur;

    WHILE finito = 0 DO
        FETCH cur INTO (fetchFile, fetchFilm, fetchTitolo, fetchPaese, fetchAbbonamento);
        
        SET presenza = (SELECT COUNT(*)
                        FROM Classifica
                        WHERE fetchFile = IDFile AND fetchPaese = Paese AND fetchAbbonamento = Abbonamento);
        
        IF presenza = 0 THEN
            INSERT INTO Classifica VALUES (fetchFile, fetchFilm, fetchTitolo, fetchPaese, fetchAbbonamento, 1);
        ELSE
            UPDATE Classifica
            SET TotaleVisualizzazioni = TotaleVisualizzazioni + 1
            WHERE fetchFile = IDFile AND fetchPaese = Paese AND fetchAbbonamento = Abbonamento;
        END IF;
    END WHILE;

    CLOSE cur;
END $$
DELIMITER ;

DROP EVENT IF EXISTS make_classifiche;
CREATE EVENT make_classifiche ON SCHEDULE EVERY 7 DAY
DO
    CALL refresh_classifiche();