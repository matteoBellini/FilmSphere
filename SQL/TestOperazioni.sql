-- Test BUILD_EDGE_SERVER e ADD_EDGE_SERVER
set @_check = 0;
CALL filmsphere.BUILD_EDGE_SERVER(@_check);
SELECT @_check;


-- Test find_best_server
SET @check = '';
SET @serverScelto = '';
CALL FilmSphere.find_best_server('E1:AF:A5:C7:BE:2A', 45, @serverScelto, @check);

SELECT @serverScelto;


-- Test inserimento utente
SET @check = '';
CALL FilmSphere.registrazione_utente('BLLMTT03E08D403H', 'Matteo', 'Bellini', '2003-05-08', 'M', 'matteo.bellini.2003@gmail.com', "password123", '366816514', 1, 'cartacarta', 'Bellini', 'Matteo', '2025-10-10', '963', @check);

SELECT @check;


-- Test scelta_abbonamento e emissioneFattura
SET @check = '';
CALL FilmSphere.scelta_abbonamento('Deluxe', 'BLLMTT03E08D403H', 'cartacarta', @check);

SELECT @check;

SELECT *
FROM FilmSphere.Utente
WHERE CF = 'BLLMTT03E08D403H';

SELECT *
FROM FilmSphere.Fattura
WHERE Utente = 'BLLMTT03E08D403H';


-- Test Find_Edge_Server
SET @check = '';
SET @serverScelto = '';
CALL FilmSphere.Find_Edge_Server('101.129.202.30', 64, @serverScelto, @check);

SELECT @serverScelto, @check;


-- Test verificaRestrizioni
SET @fileScelto = '';
CALL FilmSphere.verificaRestrizioni('0C:79:58:97:93:BC', 2, @fileScelto);

SELECT @fileScelto;


-- Test InserimentoDispositivo
INSERT INTO FilmSphere.Dispositivo (IndirizzoMac, Hardware, Risoluzione, IndirizzoIP, Utente, Paese, Latitudine, Longitudine, InizioConnessione, ServerConnesso) VALUES
('52:2D:90:9D:DE:FF', 'tablet', '2160', '183.98.223.130', 'ABC12345S123456S', 'Cuba', -0.031665, -0.01122, '2024-04-13 08:00:00', '138.111.46.240');
INSERT INTO FilmSphere.Dispositivo (IndirizzoMac, Hardware, Risoluzione, IndirizzoIP, Utente, Paese, Latitudine, Longitudine, InizioConnessione, ServerConnesso) VALUES
('52:2D:FF:9D:DE:FF', 'tablet', '2160', '183.98.223.130', 'ABC12345S123456S', 'Cuba', -0.031665, -0.01122, '2024-04-13 08:00:00', '138.111.46.240');
INSERT INTO FilmSphere.Dispositivo (IndirizzoMac, Hardware, Risoluzione, IndirizzoIP, Utente, Paese, Latitudine, Longitudine, InizioConnessione, ServerConnesso) VALUES
('52:FF:90:9D:DE:FF', 'tablet', '2160', '183.98.223.130', 'ABC12345S123456S', 'Cuba', -0.031665, -0.01122, '2024-04-13 08:00:00', '138.111.46.240');
INSERT INTO FilmSphere.Dispositivo (IndirizzoMac, Hardware, Risoluzione, IndirizzoIP, Utente, Paese, Latitudine, Longitudine, InizioConnessione, ServerConnesso) VALUES
('52:FF:90:FF:DE:FF', 'tablet', '2160', '183.98.223.130', 'ABC12345S123456S', 'Cuba', -0.031665, -0.01122, '2024-04-13 08:00:00', '138.111.46.240');

SELECT *
FROM FilmSphere.Dispositivo
WHERE Utente = 'ABC12345S123456S';


-- Test Utenti in scadenza
INSERT INTO FilmSphere.Utente (CF, Nome, Cognome, DataNascita, Sesso, Mail, PW, Telefono, RinnovoAutomatico, TipoAbbonamento, DataScadenza) VALUES
('ABC75845A123456A', 'John', 'Smith', '1990-01-01', 'M', 'john.smith@example.com', 'password123', '1234567890', 0, 'Ultimate', CURRENT_DATE + INTERVAL 1 DAY);

CALL FilmSphere.build_utenti_scadenza();
SELECT * FROM FilmSphere.UtentiInScadenza;


-- Test rating di un film
SET @rating = '';
CALL FilmSphere.ratingFilm(1, @rating);

SELECT @rating;


-- Test Classifiche
CALL FilmSphere.refresh_classifiche();

SELECT * 
FROM FilmSphere.Classifica;


-- Test Caching
CALL FilmSphere.Caching('74:87:3F:F1:89:F8');


-- Test Bilanciamento del Carico
USE FilmSphere;
WITH findServerContents AS (
    SELECT DISTINCT FM.Titolo
    FROM PoP P
        INNER JOIN File FL
        ON P.IDFile = FL.ID
        INNER JOIN Film FM
        ON FM.ID = FL.Film
    WHERE P.IPServer = '101.129.202.30'
),
RatingFilm AS(
    SELECT F.ID, F.Titolo, (0.2 * F.Recensioni) + (0.4 * F.Critica) + (0.4 * ((0.6 * F.PremiFilm) + (0.4 * F.PremiCineasta))) AS Rating
    FROM Film F
    NATURAL JOIN findServerContents FSC
),
ContenutiTarget AS (
    SELECT RF.ID, RF.Titolo
    FROM RatingFilm RF
    ORDER BY RF.Rating DESC
    LIMIT 5
)
SELECT ED.IDEdgeServer AS Destinazione, CT.Titolo, CT.ID
FROM edge_server ED
    CROSS JOIN ContenutiTarget CT
WHERE ED.IDServer = '101.129.202.30';