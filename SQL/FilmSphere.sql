DROP SCHEMA IF EXISTS FilmSphere;
CREATE SCHEMA IF NOT EXISTS FilmSphere DEFAULT CHARACTER SET utf8;

-- --------------------------------
-- CREAZIONE TABELLE
-- --------------------------------
drop table if exists FilmSphere.Genere;
create table FilmSphere.Genere(
	Nome varchar(25) primary key not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Film;
create table FilmSphere.Film(
	ID integer not null primary key auto_increment,
    Titolo varchar(255) not null,
    Descrizione varchar(500) not null,
    Durata integer UNSIGNED not null,
    AnnoDiProduzione integer not null,
    Genere varchar(25) not null,
    Recensioni integer default 0,
    NumRecensioni integer default 0,
    Critica integer default 0,
    PremiFilm integer default 0,
    PremiCineasta integer default 0,
    foreign key(Genere) references Genere(Nome)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Cineasta;
create table FilmSphere.Cineasta(
	IdCineasta integer not null auto_increment primary key,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    DataNascita date not null,
    LuogoNascita varchar(50) not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Recitazione;
create table FilmSphere.Recitazione(
	IdCineasta integer,
    Film integer,
    NomePersonaggio varchar(30) not null,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(Film) references Film(ID)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Regia;
create table FilmSphere.Regia(
	IdCineasta integer,
    Film integer,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(Film) references Film(ID)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.PremiCineasta;
create table FilmSphere.PremiCineasta(
	Id integer auto_increment primary key,
    Nome varchar(50)not null,
    Importanza integer unsigned not null,
    Categoria varchar(50) not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.PremiFilm;
create table FilmSphere.PremiFilm(
	Id integer auto_increment primary key,
    Nome varchar(50)not null,
    Importanza integer unsigned not null,
    Categoria varchar(50) not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Premiazione;
create table FilmSphere.Premiazione(
	IdCineasta integer,
    IdPremio integer,
    DataPremiazione date not null,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(IdPremio) references PremiCineasta(Id)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Vincita;
create table FilmSphere.Vincita(
	IdFilm integer,
    IdPremio integer,
    DataVincita date not null,
    foreign key(IdFilm) references Film(ID),
    foreign key(IdPremio) references PremiFilm(Id)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Abbonamento;
create table FilmSphere.Abbonamento(
	Tipo varchar(10) primary key,
    Durata integer unsigned not null,
    NoData bit(1) not null,
    NumeroDispositivi integer unsigned not null,
    RisoluzioneMassima integer not null,
    Prezzo double unsigned not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Utente;
create table FilmSphere.Utente(
	CF varchar(16) primary key,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    DataNascita date not null,
    Sesso varchar(1) not null,
    Mail varchar(50) not null,
    PW varchar(100) not null,
    Telefono varchar(10) not null,
    RinnovoAutomatico bit(1) not null,
    TipoAbbonamento varchar(10),
    DataScadenza date default null,
    foreign key(TipoAbbonamento) references Abbonamento(Tipo)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Critico;
create table FilmSphere.Critico(
    CF varchar(16) primary key,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    DataNascita date not null,
    Sesso varchar(1) not null,
    Azienda varchar(20) not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Recensione;
create table FilmSphere.Recensione(
	CFUtente varchar(16) not null,
    IDFilm integer not null,
    Testo varchar(500),
    Punteggio integer unsigned not null,
    
    primary key(CFUtente, IDFilm),
    foreign key(CFUtente) references Utente(CF),
    foreign key(IDFilm) references Film(ID)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Critica;
create table FilmSphere.Critica(
	CFUtente varchar(16) not null,
    IDFilm integer not null,
    Testo varchar(500),
    Punteggio integer unsigned not null,
    
    primary key(CFUtente, IDFilm),
    foreign key(CFUtente) references Utente(CF),
    foreign key(IDFilm) references Film(ID)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Carta;
create table FilmSphere.Carta(
	Numero varchar(16) not null primary key,
    CognomeTitolare varchar(20) not null,
    NomeTitolare varchar(20) not null,
    DataScadenza date not null,
    CVV varchar(3) not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Preferenza;
create table FilmSphere.Preferenza(
    NumCarta varchar(16),
    CF varchar(16),

    primary key(NumCarta, CF),
    foreign key (NumCarta) REFERENCES Carta(Numero),
    foreign key (CF) REFERENCES Utente(CF)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Fattura;
create table FilmSphere.Fattura(
	Numero integer not null auto_increment primary key,
    DataEmissione date not null,
    Importo double not null,
    NumeroCarta varchar(16) not null,
    Utente varchar(16) not null,
    
    foreign key(NumeroCarta) references Carta(Numero),
    foreign key(Utente) references Utente(CF)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Paese;
create table FilmSphere.Paese(
	Nome varchar(50) not null primary key,
    NumeroAbitanti integer not null,
    IPRangeStart varchar(15) not null,
    IPRangeEnd varchar(15) not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

-- latitudine e longitudine memorizzati in radianti
drop table if exists FilmSphere.Server;
create table FilmSphere.Server(
	IndirizzoIP varchar(15) not null primary key,
    Latitudine float not null,
    Longitudine float not null,
    CAPBanda integer not null,
    CAPTrasmissione integer not null,
    DimensioneCache integer not null,
    CaricoAttuale float default 0,
    Paese varchar(50) not null,
    
    foreign key(Paese) references Paese(Nome)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

-- latitudine e longitudine aggiunte in radianti
drop table if exists FilmSphere.Dispositivo;
create table FilmSphere.Dispositivo(
	IndirizzoMac varchar(17) not null primary key,
    Hardware varchar(20) not null,
    Risoluzione varchar(10) not null,
    IndirizzoIP varchar(15) not null,
    InizioConnessione datetime,
    FineConnessione datetime,
    Utente varchar(16) not null,
    Paese varchar(50) not null,
    Latitudine float,
    Longitudine float,
    ServerConnesso varchar(15) default null,
    
    foreign key(Utente) references Utente(CF),
    foreign key(Paese) references Paese(Nome),
    foreign key(ServerConnesso) references Server(IndirizzoIP)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Produzione;
create table FilmSphere.Produzione(
	IDFilm integer not null,
    Paese varchar(50) not null,
    
    primary key(IDFilm, Paese),
    foreign key(IDFilm) references Film(ID),
    foreign key(Paese) references Paese(Nome)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Restrizione;
create table FilmSphere.Restrizione(
	ID integer not null auto_increment,
    FormatoVideo integer default null,
    FormatoAudio integer default null,

    primary key(ID)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.PaeseRestrizione;
create table FilmSphere.PaeseRestrizione(
	IDRestrizione integer not null,
    Paese varchar(50) not null,
    
    primary key(IDRestrizione, Paese),
    foreign key(IDRestrizione) references Restrizione(ID),
    foreign key(Paese) references Paese(Nome)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.FormatoAudio;
create table FilmSphere.FormatoAudio(
	ID integer not null auto_increment primary key,
    MaxBitrate integer not null,
    Codec varchar(10) not null,
    Nome varchar(10) not null,
    DataRilascio date not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.FormatoVideo;
create table FilmSphere.FormatoVideo(
	ID integer not null auto_increment primary key,
    Nome varchar(10) not null,
    Codec varchar(10) not null,
    FPS integer unsigned not null,
    DataRilascio date not null
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.File;
create table FilmSphere.File(
	ID integer not null auto_increment primary key,
    Risoluzione integer not null,
    BitRate integer not null,
    QualitaAudio varchar(15) not null,
    QualitaVideo varchar(15) not null,
    AspectRatio varchar(10) not null,
    DimensioneFile double not null,
    LunghezzaVideo time not null,
    FormatoVideo integer not null,
    FormatoAudio integer not null,
    Film integer not null,
    
    foreign key(FormatoVideo) references FormatoVideo(ID),
    foreign key(FormatoAudio) references FormatoAudio(ID),
    foreign key(Film) references Film(ID)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.PoP;
create table FilmSphere.PoP(
	IDFile integer not null,
    IPServer varchar(15) not null,
    
    primary key(IDFile, IPServer),
    foreign key(IDFile) references File(ID),
    foreign key(IPServer) references Server(IndirizzoIP)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Visualizzazione;
create table FilmSphere.Visualizzazione(
    IDFile integer not null,
    Dispositivo varchar(17) not null,
    MinutoCorrente time not null,
    InizioVisualizzazione datetime,
    
    primary key(IDFile, Dispositivo),
    foreign key(IDFile) references File(ID),
    foreign key(Dispositivo) references Dispositivo(IndirizzoMac)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Lingua;
create table FilmSphere.Lingua(
	NomeLingua varchar(20) not null primary key
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Audio;
create table FilmSphere.Audio(
	IDFile integer not null,
    LinguaAudio varchar(20) not null,
    
    primary key(IDFile, LinguaAudio),
    foreign key(IDFile) references File(ID),
    foreign key(LinguaAudio) references Lingua(NomeLingua)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

drop table if exists FilmSphere.Sottotitolo;
create table FilmSphere.Sottotitolo(
	IDFile integer not null,
    LinguaSottotitolo varchar(20) not null,
    
    primary key(IDFile, LinguaSottotitolo),
    foreign key(IDFile) references File(ID),
    foreign key(LinguaSottotitolo) references Lingua(NomeLingua)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;


-- --------------------------------
-- TRIGGER
-- --------------------------------
-- Controllo dell'inserimento o modifica dell'anno di produzione di ogni film
DROP TRIGGER IF EXISTS FilmSphere.TfilmInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TFilmInsert BEFORE INSERT ON Film
FOR EACH ROW
BEGIN
    IF NEW.AnnoDiProduzione > YEAR(CURRENT_DATE) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento con Anno di Produzion non valido";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TfilmUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TFilmUpdate BEFORE UPDATE ON Film
FOR EACH ROW
BEGIN
    IF NEW.AnnoDiProduzione > YEAR(CURRENT_DATE) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento con Anno di Produzion non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo del corretto inserimento dei dati di un cineasta
DROP TRIGGER IF EXISTS FilmSphere.TCineastaInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TCineastaInsert BEFORE INSERT ON Cineasta
FOR EACH ROW
BEGIN
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

DROP TRIGGER IF EXISTS FilmSphere.TCineastaUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TCineastaUpdate BEFORE UPDATE ON Cineasta
FOR EACH ROW
BEGIN
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
DROP TRIGGER IF EXISTS FilmSphere.TPremiazioneInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TPremiazioneInsert BEFORE INSERT ON Premiazione
FOR EACH ROW
BEGIN
    IF NEW.DataPremiazione > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data premiazione non valido";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TPremiazioneUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TPremiazioneUpdate BEFORE UPDATE ON Premiazione
FOR EACH ROW
BEGIN
    IF NEW.DataPremiazione > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data premiazione non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo che i dati di una vincita siano corretti
DROP TRIGGER IF EXISTS FilmSphere.TVincitaInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TVincitaInsert BEFORE INSERT ON Vincita
FOR EACH ROW
BEGIN
    IF NEW.DataVincita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data vincita non valido";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TVincitaUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TVincitaUpdate BEFORE UPDATE ON Vincita
FOR EACH ROW
BEGIN
    IF NEW.DataVincita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data vincita non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo che i dati di un utente siano corretti
DROP TRIGGER IF EXISTS FilmSphere.TUtenteInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TUtenteInsert BEFORE INSERT ON Utente
FOR EACH ROW
BEGIN
    IF NEW.DataNascita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data Nascita non valido";
    END IF;

    IF NEW.Sesso <> 'M' AND NEW.Sesso <> 'F' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Sesso non valido";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TUtenteUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TUtenteUpdate BEFORE UPDATE ON Utente
FOR EACH ROW
BEGIN
    IF NEW.DataNascita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data Nascita non valido";
    END IF;

    IF NEW.Sesso <> 'M' AND NEW.Sesso <> 'F' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Sesso non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo che i dati di un critico siano corretti
DROP TRIGGER IF EXISTS FilmSphere.TCriticoInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TCriticoInsert BEFORE INSERT ON Critico
FOR EACH ROW
BEGIN
    IF NEW.DataNascita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data Nascita non valido";
    END IF;

    IF NEW.Sesso <> 'M' AND NEW.Sesso <> 'F' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Sesso non valido";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TCriticoUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TCriticoUpdate BEFORE UPDATE ON Critico
FOR EACH ROW
BEGIN
    IF NEW.DataNascita > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Data Nascita non valido";
    END IF;

    IF NEW.Sesso <> 'M' AND NEW.Sesso <> 'F' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di Sesso non valido";
    END IF;
END $$
DELIMITER ;

-- Business Rule per la definizione intervallo accettabile di punteggio per una recensione
DROP TRIGGER IF EXISTS FilmSphere.TRecensioneInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TRecensioneInsert BEFORE INSERT ON Recensione
FOR EACH ROW
BEGIN
    IF NEW.Punteggio > 10 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di un punteggio non valido";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TRecensioneUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TRecensioneUpdate BEFORE UPDATE ON Recensione
FOR EACH ROW
BEGIN
    IF NEW.Punteggio > 10 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di un punteggio non valido";
    END IF;
END $$
DELIMITER ;

-- Business Rule per la definizione intervallo accettabile di punteggio per una critica
DROP TRIGGER IF EXISTS FilmSphere.TCriticaInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TCriticaInsert BEFORE INSERT ON Critica
FOR EACH ROW
BEGIN
    IF NEW.Punteggio > 10 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di un punteggio non valido";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TCriticaUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TCriticaUpdate BEFORE UPDATE ON Critica
FOR EACH ROW
BEGIN
    IF NEW.Punteggio > 10 THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di un punteggio non valido";
    END IF;
END $$
DELIMITER ;

-- Controllo che la data di scadenza della carta si valida
DROP TRIGGER IF EXISTS FilmSphere.TCarta;
DELIMITER $$
CREATE TRIGGER FilmSphere.TCarta BEFORE INSERT ON Carta
FOR EACH ROW
BEGIN
    IF NEW.DataScadenza < CURRENT_DATE THEN 
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di una carta scaduta";
    END IF;
END $$
DELIMITER ;

-- Controllo che la risoluzionne di un dispositivo sia corretta
DROP TRIGGER IF EXISTS FilmSphere.TDispositivo;
DELIMITER $$
CREATE TRIGGER FilmSphere.TDispositivo BEFORE INSERT ON Dispositivo
FOR EACH ROW
BEGIN
    IF NEW.Risoluzione NOT IN ("720", "1080", "1440", "2160") THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inserimento di una risoluzione non valida";
    END IF;
END $$
DELIMITER ;

-- Controllo che la data di rilascio di un Formato Audio sia corretta
DROP TRIGGER IF EXISTS FilmSphere.TFormatoAudioInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TFormatoAudioInsert BEFORE INSERT ON FormatoAudio
FOR EACH ROW
BEGIN
    IF NEW.DataRilascio > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inseriemento di una Data di Rilascio non valida";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TFormatoAudioUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TFormatoAudioUpdate BEFORE UPDATE ON FormatoAudio
FOR EACH ROW
BEGIN
    IF NEW.DataRilascio > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inseriemento di una Data di Rilascio non valida";
    END IF;
END $$
DELIMITER ;

-- Verifica che i formati audio e video di una restrizione siano corretti
DROP TRIGGER IF EXISTS FilmSphere.RestrizioneFormatoInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.RestrizioneFormatoInsert BEFORE INSERT ON Restrizione
FOR EACH ROW
BEGIN
    DECLARE _corretto INTEGER DEFAULT NULL;

    IF NEW.FormatoVideo IS NULL AND NEW.FormatoAudio IS NOT NULL THEN
        SET _corretto = (SELECT ID
                         FROM FormatoAudio
                         WHERE ID = NEW.FormatoAudio);
    END IF;

    IF NEW.FormatoVideo IS NOT NULL AND NEW.FormatoAudio IS NULL THEN
        SET _corretto = (SELECT ID
                         FROM FormatoVideo
                         WHERE ID = NEW.FormatoVideo);
    END IF;

    -- Se trovasse un ID presente ed uno no si andrebbe a sommare un numero a NULL, per cui si ottiene comunque NULL
    IF NEW.FormatoVideo IS NOT NULL AND NEW.FormatoAudio IS NOT NULL THEN
        SET _corretto = (SELECT ID
                         FROM FormatoVideo
                         WHERE ID = NEW.FormatoVideo);

        SET _corretto = _corretto + (SELECT ID
                                     FROM FormatoAudio
                                     WHERE ID = NEW.FormatoAudio);
    END IF;

    IF _corretto IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "I Formati della restrizione non sono corretti";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.RestrizioneFormatoUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.RestrizioneFormatoUpdate BEFORE UPDATE ON Restrizione
FOR EACH ROW
BEGIN
    DECLARE _corretto INTEGER DEFAULT NULL;

    IF NEW.FormatoVideo IS NULL AND NEW.FormatoAudio IS NOT NULL THEN
        SET _corretto = (SELECT ID
                         FROM FormatoAudio
                         WHERE ID = NEW.FormatoAudio);
    END IF;

    IF NEW.FormatoVideo IS NOT NULL AND NEW.FormatoAudio IS NULL THEN
        SET _corretto = (SELECT ID
                         FROM FormatoVideo
                         WHERE ID = NEW.FormatoVideo);
    END IF;

    -- Se trovasse un ID presente ed uno no si andrebbe a sommare un numero a NULL, per cui si ottiene comunque NULL
    IF NEW.FormatoVideo IS NOT NULL AND NEW.FormatoAudio IS NOT NULL THEN
        SET _corretto = (SELECT ID
                         FROM FormatoVideo
                         WHERE ID = NEW.FormatoVideo);

        SET _corretto = _corretto + (SELECT ID
                                     FROM FormatoAudio
                                     WHERE ID = NEW.FormatoAudio);
    END IF;

    IF _corretto IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "I Formati della restrizione non sono corretti";
    END IF;
END $$
DELIMITER ;

-- Controllo che la data di rilascio di un Formato Video sia corretta
DROP TRIGGER IF EXISTS FilmSphere.TFormatoVideoInsert;
DELIMITER $$
CREATE TRIGGER FilmSphere.TFormatoVideoInsert BEFORE INSERT ON FormatoVideo
FOR EACH ROW
BEGIN
    IF NEW.DataRilascio > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inseriemento di una Data di Rilascio non valida";
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.TFormatoVideoUpdate;
DELIMITER $$
CREATE TRIGGER FilmSphere.TFormatoVideoUpdate BEFORE UPDATE ON FormatoVideo
FOR EACH ROW
BEGIN
    IF NEW.DataRilascio > CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Inseriemento di una Data di Rilascio non valida";
    END IF;
END $$
DELIMITER ;

-- Aggiunta del carico di un server nel momento in cui inizia una visualizzazione
DROP TRIGGER IF EXISTS FilmSphere.AddCaricoInsert
DELIMITER $$
CREATE TRIGGER FilmSphere.AddCaricoInsert AFTER INSERT ON Visualizzazione
FOR EACH ROW
BEGIN
    DECLARE carico FLOAT DEFAULT 0;
    DECLARE risoluzione INTEGER DEFAULT 0;
    DECLARE bitrate INTEGER DEFAULT 0;
    DECLARE _server VARCHAR(15) DEFAULT '';
    DECLARE _caricoServer FLOAT DEFAULT 0;

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
                         WHERE IndirizzoIP = _server);

    SET carico = (risoluzione / 20 + bitrate / 100) / 600;
    -- SET carico = 50;     -- per verificare che il trigger funziona (nel popolamento ci sono pochi utenti)

    IF _server IS NOT NULL THEN
        IF _caricoServer + carico > 90 THEN
            CALL Find_Edge_Server(_server, NEW.IDFile);
        ELSE
            SET SQL_SAFE_UPDATES = 0;

            UPDATE Server
            SET CaricoAttuale = _caricoServer + carico
            WHERE IndirizzoIP = _server;

            SET SQL_SAFE_UPDATES = 1;
        END IF;
    END IF;
END $$
DELIMITER ;

DROP TRIGGER IF EXISTS FilmSphere.AddCaricoUpdate
DELIMITER $$
CREATE TRIGGER FilmSphere.AddCaricoUpdate BEFORE UPDATE ON Visualizzazione
FOR EACH ROW
BEGIN
    DECLARE carico FLOAT DEFAULT 0;
    DECLARE risoluzione INTEGER DEFAULT 0;
    DECLARE bitrate INTEGER DEFAULT 0;
    DECLARE _server VARCHAR(15) DEFAULT '';
    DECLARE _caricoServer FLOAT DEFAULT 0;

    DECLARE vecchioMinutoCorrente TIME;

    SET vecchioMinutoCorrente = (SELECT MinutoCorrente
                                 FROM Visualizzazione
                                 WHERE IDFile = NEW.IDFile AND Dispositivo = NEW.Dispositivo);

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
                         WHERE IndirizzoIP = _server);

    SET carico = (risoluzione / 20 + bitrate / 100) / 600;

    IF vecchioMinutoCorrente < NEW.MinutoCorrente THEN
        IF _server IS NOT NULL THEN
            IF _caricoServer + carico > 90 THEN
                CALL Find_Edge_Server(_server, NEW.IDFile);
            ELSE
                SET SQL_SAFE_UPDATES = 0;

                UPDATE Server
                SET CaricoAttuale = _caricoServer + carico
                WHERE IndirizzoIP = _server;

                SET SQL_SAFE_UPDATES = 1;
            END IF;
        END IF;
    END IF;
END $$
DELIMITER ;

-- Rimozione del carico da un server nel momento in cui una connessione termina
DROP TRIGGER IF EXISTS FilmSphere.SubCarico;
DELIMITER $$
CREATE TRIGGER FilmSphere.SubCarico AFTER UPDATE ON Dispositivo
FOR EACH ROW
BEGIN
    DECLARE _file INTEGER DEFAULT 0;
    DECLARE risoluzione INTEGER DEFAULT 0;
    DECLARE bitrate INTEGER DEFAULT 0;
    DECLARE carico FLOAT DEFAULT 0;

    IF NEW.FineConnessione IS NOT NULL THEN
        SET _file = (SELECT IDFile
                     FROM Visualizzazione
                     WHERE Dispositivo = NEW.IndirizzoMac
                     ORDER BY InizioVisualizzazione DESC
                     LIMIT 1);
        SET risoluzione = (SELECT Risoluzione
                           FROM File
                           WHERE ID = _file);

        SET bitrate = (SELECT Bitrate
                       FROM File
                       WHERE ID = _file);

        SET carico = (risoluzione / 20 + bitrate / 100) / 600;
        -- SET carico = 50;

        UPDATE Server
        SET CaricoAttuale = CaricoAttuale - carico
        WHERE IndirizzoIP = NEW.ServerConnesso;
    END IF;
END $$
DELIMITER ;

-- Verifica che ci sia spazio a sufficienza per l'inserimento di un film nella cache di un server
DROP TRIGGER IF EXISTS FilmSphere.VerificaSpazio;
DELIMITER $$
CREATE TRIGGER FilmSphere.VerificaSpazio BEFORE INSERT ON PoP
FOR EACH ROW
BEGIN
    DECLARE _DimensioneFile INTEGER DEFAULT 0;
    DECLARE _DimensioneCache INTEGER DEFAULT 0;
    DECLARE _spazioUtilizzato INTEGER DEFAULT 0;

    SET _DimensioneFile = (SELECT DimensioneFile
                          FROM File
                          WHERE ID = NEW.IDFile);

    SET _DimensioneCache = (SELECT DimensioneCache
                            FROM Server
                            WHERE IndirizzoIP = NEW.IPServer);

    SET _spazioUtilizzato = (SELECT SUM(DimensioneFile)
                             FROM PoP P
                                INNER JOIN File F
                                ON F.ID = P.IDFile
                             WHERE P.IPServer = NEW.IPServer);

    IF _spazioUtilizzato + _DimensioneFile > _DimensioneCache THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "La Cache del server è piena";
    END IF;
END $$
DELIMITER ;


-- ------------------------------
-- OPERAZIONI
-- ------------------------------
-- --------------------------------------
-- Inserimento di un nuovo utente
-- --------------------------------------
DROP PROCEDURE IF EXISTS FilmSphere.registrazione_utente;
DELIMITER $$
CREATE PROCEDURE FilmSphere.registrazione_utente(IN _CF VARCHAR(16),IN _Nome VARCHAR(20),IN _Cognome VARCHAR(20),IN _DataNascita DATE,IN _Sesso VARCHAR(1),IN _Mail VARCHAR(50),
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
            VALUES(_NumCarta, _cognTit, _nomTit, _DataScad, _cvv);
        END IF;

        INSERT INTO Utente(CF, Nome, Cognome, DataNascita, Sesso, Mail, PW, Telefono, RinnovoAutomatico)
        VALUES(_CF, _Nome, _Cognome, _DataNascita, _Sesso, _Mail, _Password, _Telefono, _RinnovoAutomatico);
        
        INSERT INTO Preferenza
            VALUES(_NumCarta, _CF);
    	
        SET _check = TRUE;
    END IF;
    
END $$
DELIMITER ;

-- --------------------------------------
-- Emissione Fattura
-- --------------------------------------
DROP PROCEDURE IF EXISTS FilmSphere.emissione_fattura;
DELIMITER $$
CREATE PROCEDURE FilmSphere.emissione_fattura(IN _utente VARCHAR(16), IN _abb VARCHAR(10), IN _NumCarta VARCHAR(16))
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
DROP PROCEDURE IF EXISTS FilmSphere.scelta_abbonamento;
DELIMITER $$
CREATE PROCEDURE FilmSphere.scelta_abbonamento(IN _abb VARCHAR(10), IN _CF VARCHAR(16), IN _NumCarta VARCHAR(16), OUT _check BOOL)
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
    
    IF temp1 = 0 OR temp2 = 0 OR temp3 IS NOT NULL OR temp4 = 0 THEN
    	SET _check = FALSE;
	ELSE
        SET durataAbbonamento = (SELECT Durata
                                 FROM Abbonamento
                                 WHERE Tipo = _abb);

        
        SET SQL_SAFE_UPDATES = 0;

    	UPDATE Utente U
        SET U.TipoAbbonamento = _abb , U.DataScadenza = CURRENT_DATE + INTERVAL durataAbbonamento DAY
    	WHERE U.CF = _CF;

        SET SQL_SAFE_UPDATES = 1;

        SET _check = TRUE;
        CALL emissione_fattura(_CF, _abb, _numCarta);
    END IF;
END $$
DELIMITER ;

-- --------------------------------------
-- Individuazione del server migliore ad ogni nuova connessione (Latitudine e Longitudine memorizzate in radianti)
-- --------------------------------------
DROP PROCEDURE IF EXISTS FilmSphere.find_best_server;
DELIMITER $$
CREATE PROCEDURE FilmSphere.find_best_server(IN _Dispositivo VARCHAR(17), IN targetFile INTEGER, OUT resultServer VARCHAR(15), OUT _check BOOL)
BEGIN 
	DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchServer VARCHAR(15) DEFAULT '';
    DECLARE fetchLat FLOAT DEFAULT 0;
    DECLARE fetchLong FLOAT DEFAULT 0;
    DECLARE presenza INTEGER DEFAULT 0;
    DECLARE distanza FLOAT DEFAULT 0;
    DECLARE distanzaMin FLOAT DEFAULT 100000;
    DECLARE _Latitudine FLOAT DEFAULT NULL;
    DECLARE _Longitudine FLOAT DEFAULT NULL;
    
    DECLARE cur CURSOR FOR
    	SELECT S.IndirizzoIP, S.Latitudine, S.Longitudine
        FROM Server S
        WHERE S.CaricoAttuale < 90;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    SELECT Latitudine, Longitudine INTO _Latitudine, _Longitudine
    FROM Dispositivo
    WHERE IndirizzoMac = _Dispositivo;

    SET _check = FALSE;
    SET resultServer = NULL;
    
    OPEN cur;
    
    ciclo: LOOP
        IF finito = 1 THEN
            LEAVE ciclo;
        END IF;

        FETCH cur INTO fetchServer, fetchLat, fetchLong;

        SET presenza = (SELECT COUNT(*)
                        FROM PoP 
                        WHERE IPServer = fetchServer AND IDFile = targetFile);

        IF presenza = 0 THEN
            ITERATE ciclo;
        END IF;

        SET distanza = ACOS(
			(COS(_Latitudine) * COS(_Longitudine) * COS(fetchLat) * COS(fetchLong)) +
			(COS(_Latitudine) * SIN(_Longitudine) * COS(fetchLat) * SIN(fetchLong)) +
			(SIN(_Latitudine) * SIN(fetchLat))
		) * 6371;

        IF distanza < 1500 THEN
            SET resultServer = fetchServer;
            LEAVE ciclo;
        END IF;
    END LOOP;
    
    SET _check = TRUE;
    CLOSE cur;
    
    IF resultServer IS NULL THEN
        SET resultServer = (SELECT S.IndirizzoIP
                            FROM Server S
                            WHERE S.CaricoAttuale < 90 AND ACOS(
                                                                (COS(_Latitudine) * COS(_Longitudine) * COS(S.Latitudine) * COS(S.Longitudine)) +
                                                                (COS(_Latitudine) * SIN(_Longitudine) * COS(S.Latitudine) * SIN(S.Longitudine)) +
                                                                (SIN(_Latitudine) * SIN(S.Latitudine))
                                                        ) * 6371 < 1500
                            LIMIT 1);
    	CALL CaricaFile(resultServer, targetFile, _check);
    END IF;
END $$
DELIMITER ;

/*DISTANZA COORDINATE: distanza = √((6371 * cos(lat₁) * Δlon)² + (6371 * Δlat)²) (Latitudine e Longitudine memorizzate in radianti)*/
DROP TABLE IF EXISTS FilmSphere.EDGE_SERVER;
DELIMITER $$
CREATE TABLE FilmSphere.EDGE_SERVER(
	IDServer VARCHAR(15) NOT NULL,
  	IDEdgeServer VARCHAR(15) NOT NULL,
  	Distanza FLOAT NOT NULL,
  	PRIMARY KEY (IDServer, IDEdgeServer)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

DROP PROCEDURE IF EXISTS FilmSphere.BUILD_EDGE_SERVER$$
CREATE PROCEDURE FilmSphere.BUILD_EDGE_SERVER (OUT _check BOOL)
BEGIN
	DECLARE finito INTEGER DEFAULT 0;
	DECLARE IpServer VARCHAR(15) DEFAULT '';
    DECLARE fetchLatitudine FLOAT DEFAULT 0;
    DECLARE fetchLongitudine FLOAT DEFAULT 0;

    DECLARE cur CURSOR FOR
    	SELECT IndirizzoIP, Latitudine, Longitudine
    	FROM Server;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;
    
    SET _check = FALSE;
    
    OPEN cur;
    
    WHILE finito = 0 DO
    	FETCH cur INTO IpServer, fetchLatitudine, fetchLongitudine;
		CALL ADD_EDGE_SERVER(IpServer, fetchLatitudine, fetchLongitudine);
    END WHILE;
    
    SET _check = TRUE;
    
    CLOSE cur;
	
END $$

DROP PROCEDURE IF EXISTS FilmSphere.ADD_EDGE_SERVER$$
CREATE PROCEDURE FilmSphere.ADD_EDGE_SERVER(IN IpServer VARCHAR(15), IN _Latitudine FLOAT, IN _Longitudine FLOAT)
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
    	FETCH cur INTO fetchServer, fetchLat, fetchLong;
        
        SET distanza = ACOS(
			(COS(_Latitudine) * COS(_Longitudine) * COS(fetchLat) * COS(fetchLong)) +
			(COS(_Latitudine) * SIN(_Longitudine) * COS(fetchLat) * SIN(fetchLong)) +
			(SIN(_Latitudine) * SIN(fetchLat))
			) * 6371;
            
        IF distanza < 1500 THEN
        	INSERT IGNORE INTO EDGE_SERVER VALUES (IpServer, fetchServer, distanza);
        END IF;
    END WHILE;

    CLOSE cur;
END $$
DELIMITER ;

-- Ipotizziamo che i server vengano posti ad una distanza adeguata da permette ad ogni server di avere almeno 1 edge server.
DROP PROCEDURE IF EXISTS FilmSphere.Find_Edge_Server;
DELIMITER $$
CREATE PROCEDURE FilmSphere.Find_Edge_Server(IN _Server VARCHAR(15), IN _File INTEGER, OUT _ServerScelto VARCHAR(15), OUT _check BOOL)
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchServer VARCHAR(15) DEFAULT NULL;
    DECLARE fetchDistanza FLOAT DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT ED.IDEdgeServer, ED.Distanza
        FROM EDGE_SERVER ED
            INNER JOIN Server S
            ON S.IndirizzoIP = ED.IDEdgeServer
        WHERE ED.IDServer = _Server AND S.CaricoAttuale < 90
        ORDER BY ED.Distanza;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    OPEN cur;
    
    WHILE finito = 0 DO
        FETCH cur INTO fetchServer, fetchDistanza;
        SET _ServerScelto = (SELECT S.IndirizzoIP
                             FROM Server S
                                INNER JOIN PoP P
                                ON S.IndirizzoIP = P.IPServer
                             WHERE P.IDFile = _File AND S.IndirizzoIP = fetchServer);
        IF _ServerScelto IS NOT NULL THEN 
            SET finito = 1;
        END IF;
    END WHILE;

    IF _ServerScelto IS NULL THEN
        CALL Find_Edge_Server_Free_Cache(_Server, _File, _ServerScelto);
        CALL CaricaFile(_ServerScelto, _File, _check);
	END IF;
    
    CLOSE cur;

    SET _check = TRUE;
END $$
DELIMITER ;

-- Trova un Edge Server con spazio a sufficenza in cache per memorizzare il film in ingresso
DROP PROCEDURE IF EXISTS FilmSphere.Find_Edge_Server_Free_Cache;
DELIMITER $$
CREATE PROCEDURE FilmSphere.Find_Edge_Server_Free_Cache(IN _Server VARCHAR(15), IN _File INTEGER, OUT _resultServer VARCHAR(15))
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchServer VARCHAR(15) DEFAULT '';
    DECLARE fetchDistanza FLOAT DEFAULT 0;
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
        FETCH cur INTO fetchServer, fetchDistanza;
        SET _dimensioneCache = (SELECT DimensioneCache
                                FROM Server
                                WHERE IndirizzoIP = fetchServer);

        SET spazioOccupato = (SELECT SUM(DimensioneFile)
                              FROM PoP P
                                  INNER JOIN File F
                                  ON F.ID = P.IDFile
                              WHERE P.IPServer = fetchServer);
        
        IF spazioOccupato + dimensioneFilm <= _dimensioneCache THEN
            SET _resultServer = fetchServer;
            SET finito = 1;
        END IF;
    END WHILE;
    
    CLOSE cur;
END $$
DELIMITER ;

-- Aggiunta di un file all'interno di un Server (Si aggiunge il file alla relazione POP)
DROP PROCEDURE IF EXISTS FilmSphere.CaricaFile;
DELIMITER $$
CREATE PROCEDURE FilmSphere.CaricaFile (IN _Server VARCHAR(15), IN _file INTEGER, OUT _check BOOL)
BEGIN
    INSERT INTO PoP VALUES (_file, _Server);
    SET _check = TRUE;
END $$
DELIMITER ;

-- --------------------------------------
-- Individuazione dei film che un utente può vedere in un certo paese (non sottoposti a restrizioni)
-- --------------------------------------
DROP PROCEDURE IF EXISTS FilmSphere.VerificaRestrizioni;
DELIMITER $$
CREATE PROCEDURE FilmSphere.VerificaRestrizioni(IN _IndirizzoMAC VARCHAR(17), IN _Utente VARCHAR(16), IN _Paese VARCHAR(50), IN _Film INTEGER, OUT _IDFile INTEGER)
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
        FETCH cur INTO fetchID, fetchRisoluzione, fetchAudio, fetchVideo;
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
DROP TRIGGER IF EXISTS FilmSphere.InserimentoDispositivo;
DELIMITER $$
CREATE TRIGGER FilmSphere.InserimentoDispositivo BEFORE INSERT ON Dispositivo
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
                            WHERE D.Utente = NEW.Utente AND D.FineConnessione IS NULL AND D.InizioConnessione IS NOT NULL);

    IF numDispositiviON = maxDispositiviON THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = "Hai raggiunto il numero massimo di dispositivi connessi contemporaneamente.";
    END IF;

END $$
DELIMITER ;

-- --------------------------------------
-- Invio di una notifica il giorno precedente della scadenza dell'abbonamento
-- --------------------------------------
DROP TABLE IF EXISTS FilmSphere.UtentiInScadenza;
CREATE TABLE FilmSphere.UtentiInScadenza(
    Utente VARCHAR(16) NOT NULL PRIMARY KEY
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

DROP PROCEDURE IF EXISTS FilmSphere.build_utenti_scadenza;
DELIMITER $$
CREATE PROCEDURE FilmSphere.build_utenti_scadenza()
BEGIN
    DECLARE fetchCF VARCHAR(16) DEFAULT NULL;
    DECLARE finito INTEGER DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT CF
        FROM Utente 
        WHERE DATEDIFF(DataScadenza, CURRENT_DATE) = 1 AND RinnovoAutomatico = 0;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    TRUNCATE UtentiInScadenza;

    OPEN cur;

    WHILE finito = 0 DO
        FETCH cur INTO fetchCF;

        INSERT IGNORE INTO UtentiInScadenza (Utente) VALUES (fetchCF);
    END WHILE;

    CLOSE cur;
END $$
DELIMITER ;

DROP EVENT IF EXISTS FilmSphere.invioNotificaScadenza;
CREATE EVENT FilmSphere.invioNotificaScadenza ON SCHEDULE EVERY 1 DAY
DO 
    CALL FilmSphere.build_utenti_scadenza();

-- --------------------------------------
-- Rating di un film
-- --------------------------------------
-- Trigger relativo alle critiche
DROP TRIGGER IF EXISTS FilmSphere.rating_critiche;
DELIMITER $$
CREATE TRIGGER FilmSphere.rating_critiche AFTER INSERT ON Critica
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
DROP TRIGGER IF EXISTS FilmSphere.rating_recensioni;
DELIMITER $$
CREATE TRIGGER FilmSphere.rating_recensioni AFTER INSERT ON Recensione
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
DROP TRIGGER IF EXISTS FilmSphere.rating_premi_film;
DELIMITER $$
CREATE TRIGGER FilmSphere.rating_premi_film AFTER INSERT ON Vincita
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
DROP TRIGGER IF EXISTS FilmSphere.rating_premi_cineasta;
DELIMITER $$
CREATE TRIGGER FilmSphere.rating_premi_cineasta AFTER INSERT ON Premiazione
FOR EACH ROW
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchFilm INTEGER DEFAULT 0;
    DECLARE ratingRecitazione INTEGER DEFAULT 0;
    DECLARE numeroPremiRecitazione INTEGER DEFAULT 0;
    DECLARE ratingRegia INTEGER DEFAULT 0;
    DECLARE numeroPremiRegia INTEGER DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT Film
        FROM Recitazione
        WHERE IdCineasta = NEW.IdCineasta;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finito = 1;

    OPEN cur;

    WHILE finito = 0 DO
        FETCH cur INTO fetchFilm;

        SELECT SUM(PC.Importanza) AS SommaImportanzaPremi, COUNT(*) AS nPremi INTO ratingRecitazione, numeroPremiRecitazione
        FROM Recitazione R
            INNER JOIN Premiazione P
            ON R.IdCineasta = P.IdCineasta
            INNER JOIN PremiCineasta PC
            ON P.IdPremio = PC.ID
        WHERE R.Film = fetchFilm;

        SELECT SUM(PC.Importanza) AS SommaImportanzaPremi2, COUNT(*) AS nPremi2 INTO ratingRegia, numeroPremiRegia
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

    CLOSE cur;
END $$
DELIMITER ;

-- Procedure che restituisce il Rating di un film in ingresso
DROP PROCEDURE IF EXISTS FilmSphere.ratingFilm;
DELIMITER $$
CREATE PROCEDURE FilmSphere.ratingFilm(IN _film INTEGER, OUT _rating DOUBLE)
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
DROP PROCEDURE IF EXISTS FilmSphere.Caching;
DELIMITER $$
CREATE PROCEDURE FilmSphere.Caching (IN _Dispositivo VARCHAR(17))
BEGIN
    DECLARE _Paese VARCHAR(20) DEFAULT '';
    DECLARE _Abbonamento VARCHAR(10) DEFAULT '';
    DECLARE GenerePreferito VARCHAR(25) DEFAULT '';
    DECLARE _RisoluzioneMassima INTEGER DEFAULT 0;

    SET GenerePreferito = (WITH NumV AS (
                                SELECT F2.Genere, COUNT(*) as NumeroVisualizzazioni
                                FROM Visualizzazione V
                                    INNER JOIN File F1
                                    ON F1.ID = V.IDFile
                                    INNER JOIN Film F2
                                    ON F1.Film = F2.ID
                                WHERE V.Dispositivo = _Dispositivo
                                GROUP BY F2.Genere
                                ORDER BY NumeroVisualizzazioni DESC
                                LIMIT 1
                            )
                          SELECT Genere
                          FROM NumV);

    SET _Paese = (SELECT Paese
                  FROM Dispositivo
                  WHERE IndirizzoMac = _Dispositivo);

    SELECT U.TipoAbbonamento, A.RisoluzioneMassima INTO _Abbonamento, _RisoluzioneMassima
    FROM Dispositivo D
        INNER JOIN Utente U
        ON D.Utente = U.CF
        INNER JOIN Abbonamento A
        ON U.TipoAbbonamento = A.Tipo 
    WHERE D.IndirizzoMac = _Dispositivo;
    
    WITH FilmVisti AS(
        SELECT F.Film
        FROM Visualizzazione V
            INNER JOIN File F
            ON F.ID = V.IDFile
        WHERE V.Dispositivo = _Dispositivo
    ),
    FileBestRes AS (
        SELECT F1.ID, F1.Film
        FROM File F1
            INNER JOIN Film F2
            ON F1.Film = F2.ID
            LEFT OUTER JOIN FilmVisti FV
            ON FV.Film = F1.Film
        WHERE FV.Film IS NULL AND F2.Genere = GenerePreferito AND F1.Risoluzione = _RisoluzioneMassima
    )
    SELECT FBR.ID, FBR.Film, C.Titolo
    FROM Classifica C
        INNER JOIN FileBestRes FBR 
        ON C.IDFilm = FBR.Film
    WHERE C.Paese = _Paese AND C.Abbonamento = _Abbonamento
    ORDER BY C.TotaleVisualizzazioni DESC
    LIMIT 2;
    
    /*
    -- SELECT C.IDFile, C.IDFilm, C.Titolo
    SELECT *
    FROM Classifica C
        LEFT OUTER JOIN Visualizzazione V
        ON V.IDFile = C.IDFile
        INNER JOIN Film F
        ON F.ID = C.IDFilm
    WHERE V.Dispositivo <> _Dispositivo AND C.Paese = _Paese
        AND C.Abbonamento = _Abbonamento AND F.Genere = GenerePreferito
    ORDER BY C.TotaleVisualizzazioni DESC
    -- LIMIT 2;
    */
END $$
DELIMITER ;


-- -------------------------------
-- ANALYTICS
-- -------------------------------
DROP TABLE IF EXISTS FilmSphere.log_classifiche;
CREATE TABLE FilmSphere.log_classifiche (
    IDFile INTEGER NOT NULL,
    Abbonamento VARCHAR(10) NOT NULL,
    Paese VARCHAR(50) NOT NULL,
    DataVisualizzazione DATETIME NOT NULL,

    PRIMARY KEY(IDFile, Abbonamento, Paese, DataVisualizzazione)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS FilmSphere.Classifica;
CREATE TABLE FilmSphere.Classifica (
    IDFile INTEGER NOT NULL,
    IDFilm INTEGER NOT NULL,
    Titolo VARCHAR(255) NOT NULL,
    Paese VARCHAR(50) NOT NULL,
    Abbonamento VARCHAR(10) NOT NULL,
    TotaleVisualizzazioni INTEGER NOT NULL,

    PRIMARY KEY(IDFile, Paese, Abbonamento)
)ENGINE = InnoDB DEFAULT CHARSET=latin1;

-- Trigger di push
DROP TRIGGER IF EXISTS FilmSphere.push_log_classifiche;
DELIMITER $$
CREATE TRIGGER FilmSphere.push_log_classifiche AFTER INSERT ON Visualizzazione
FOR EACH ROW
BEGIN
    DECLARE _abbonamento VARCHAR(10) DEFAULT '';
    DECLARE _paese VARCHAR(50) DEFAULT '';
    
    SET _abbonamento = (SELECT U.TipoAbbonamento
                        FROM Dispositivo D
                            INNER JOIN Utente U
                            ON U.CF = D.Utente
                        WHERE D.IndirizzoMac = NEW.Dispositivo);

    SET _paese = (SELECT Paese
                  FROM Dispositivo
                  WHERE IndirizzoMac = NEW.Dispositivo);

    INSERT INTO log_classifiche VALUES(NEW.IDFile, _abbonamento, _paese, NEW.InizioVisualizzazione);
END $$
DELIMITER ;

-- incremental refresh in modalità completa
DROP PROCEDURE IF EXISTS FilmSphere.refresh_classifiche;
DELIMITER $$
CREATE PROCEDURE FilmSphere.refresh_classifiche()
BEGIN
    DECLARE finito INTEGER DEFAULT 0;
    DECLARE fetchFile INTEGER DEFAULT 0;
    DECLARE fetchFilm INTEGER DEFAULT NULL;
    DECLARE fetchTitolo VARCHAR(255) DEFAULT '';
    DECLARE fetchPaese VARCHAR(50) DEFAULT '';
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
    
    OPEN cur;

    WHILE finito = 0 DO
        FETCH cur INTO fetchFile, fetchFilm, fetchTitolo, fetchPaese, fetchAbbonamento;
        
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

    TRUNCATE log_classifiche;
END $$
DELIMITER ;

DROP EVENT IF EXISTS FilmSphere.make_classifiche;
CREATE EVENT FilmSphere.make_classifiche ON SCHEDULE EVERY 7 DAY
DO
    CALL refresh_classifiche();
