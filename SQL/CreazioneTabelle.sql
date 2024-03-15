drop table if exists Film;
create table Film(
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
);

drop table if exists Genere;
create table Genere(
	Nome varchar(25) primary key not null
);

drop table if exists Cineasta;
create table Cineasta(
	IdCineasta integer not null auto_increment primary key,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    DataNascita date not null,
    LuogoNascita varchar(30) not null
);

drop table if exists Recitazione;
create table Recitazione(
	IdCineasta integer,
    Film integer,
    NomePersonaggio varchar(30) not null,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(Film) references Film(ID)
);

drop table if exists Regia;
create table Regia(
	IdCineasta integer,
    Film integer,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(Film) references Film(ID)
);

drop table if exists PremiCineasta;
create table PremiCineasta(
	Id integer auto_increment primary key,
    Nome varchar(50)not null,
    Importanza integer unsigned not null,
    Categoria varchar(50) not null
);

drop table if exists PremiFilm;
create table PremiFilm(
	Id integer auto_increment primary key,
    Nome varchar(50)not null,
    Importanza integer unsigned not null,
    Categoria varchar(50) not null
);

drop table if exists Premiazione;
create table Premiazione(
	IdCineasta integer,
    IdPremio integer,
    DataPremiazione date not null,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(IdPremio) references PremiCineasta(Id)
);

drop table if exists Vincita;
create table Vincita(
	IdFilm integer,
    IdPremio integer,
    DataVincita date not null,
    foreign key(IdFilm) references Film(ID),
    foreign key(IdPremio) references PremiFilm(Id)
);

drop table if exists Utente;
create table Utente(
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
);

drop table if exists Abbonamento;
create table Abbonamento(
	Tipo varchar(10) primary key,
    Durata integer unsigned not null,
    NoData bit(1) not null,
    NumeroDispositivi integer unsigned not null,
    RisoluzioneMassima integer not null,
    Prezzo double unsigned not null
);

drop table if exists Critico;
create table Critico(
    CF varchar(16) primary key,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    DataNascita date not null,
    Sesso varchar(1) not null,
    Azienda varchar(20) not null
);

drop table if exists Recensione;
create table Recensione(
	CFUtente varchar(16) not null,
    IDFilm integer not null,
    Testo varchar(500),
    Punteggio integer unsigned not null,
    
    primary key(CFUtente, IDFilm),
    foreign key(CFUtente) references Utente(CF),
    foreign key(IDFilm) references Film(ID)
);

drop table if exists Critica;
create table Critica(
	CFUtente varchar(16) not null,
    IDFilm integer not null,
    Testo varchar(500),
    Punteggio integer unsigned not null,
    
    primary key(CFUtente, IDFilm),
    foreign key(CFUtente) references Utente(CF),
    foreign key(IDFilm) references Film(ID)
);

drop table if exists Carta;
create table Carta(
	Numero varchar(16) not null primary key,
    CognomeTitolare varchar(20) not null,
    NomeTitolare varchar(20) not null,
    DataScadenza date not null,
    CVV varchar(3) not null,
);

drop table if exists Preferenza;
create table Preferenza(
    NumCarta varchar(16),
    CF varchar(16),

    primary key(NumCarta, CF),
    foreign key (NmCarta) REFERENCES Carta(Numero),
    foreign key (CF) REFERENCES Utente(CF)
);

drop table if exists Fattura;
create table Fattura(
	Numero integer not null auto_increment primary key,
    DataEmissione date not null,
    Importo double not null,
    NumeroCarta varchar(16) not null,
    Utente varchar(16) not null,
    
    foreign key(NumeroCarta) references Carta(Numero),
    foreign key(Utente) references Utente(CF)
);
-- latitudine e longitudine aggiunte in radianti
drop table if exists Dispositivo;
create table Dispositivo(
	IndirizzoMAC varchar(17) not null primary key,
    Hardware varchar(20) not null,
    Risoluzione varchar(10) not null,
    IndirizzoIP varchar(15) not null,
    InizioConnessione datetime,
    FineConnessione datetime,
    Utente varchar(16) not null,
    Paese varchar(20) not null,
    Latitudine float,
    Longitudine float,
    ServerConnesso varchar(15) not null,
    
    foreign key(Utente) references Utente(CF),
    foreign key(Paese) references Paese(Nome),
    foreign key(ServerConnesso) references Server(IndirizzoIP)
);

drop table if exists Paese;
create table Paese(
	Nome varchar(20) not null primary key,
    NumeroAbitanti integer not null,
    IPRangeStart varchar(10) not null,
    IPRangeEnd varchar(10) not null
);

drop table if exists Produzione;
create table Produzione(
	IDFilm integer not null,
    Paese varchar(20) not null,
    
    primary key(IDFilm, Paese),
    foreign key(IDFilm) references Film(ID),
    foreign key(Paese) references Paese(Nome)
);

drop table if exists Restrizione;
create table Restrizione(
	ID integer not null auto_increment,
    FormatoVideo integer default null,
    FormatoAudio integer default null,

    primary key(ID)
);

drop table if exists PaeseRestrizione;
create table PaeseRestrizione(
	IDRestrizione integer not null,
    Paese varchar(20) not null,
    
    primary key(IDRestrizione, Paese),
    foreign key(IDRestrizione) references Restrizione(ID),
    foreign key(Paese) references Paese(Nome)
);
-- latitudine e longitudine memorizzati in radianti
drop table if exists Server;
create table Server(
	IndirizzoIP varchar(15) not null primary key,
    Latitudine float not null,
    Longitudine float not null,
    CAPBanda integer not null,
    CAPTrasmissione integer not null,
    DimensioneCache integer not null,
    CaricoAttuale float not null,
    Paese varchar(20) not null,
    
    foreign key(Paese) references Paese(Nome)
);

drop table if exists PoP;
create table PoP(
	IDFile integer not null,
    IPServer varchar(15) not null,
    
    primary key(IDFile, IPServer),
    foreign key(IDFile) references File(ID),
    foreign key(IPServer) references Server(IndirizzoIP)
);

drop table if exists Visualizzazione;
create table Visualizzazione(
    IDFile integer not null,
    Dispositivo varchar(17) not null,
    MinutoCorrente time not null,
    InizioVisualizzazione datetime
    
    primary key(IDFile, Dispositivo),
    foreign key(IDFile) references File(ID),
    foreign key(Dispositivo) references Dispositivo(IndirizzoMAC)
);

drop table if exists File;
create table File(
	ID integer not null auto_increment primary key,
    Risoluzione integer not null,
    BitRate integer not null,
    QualitaAudio varchar(15) not null,
    QualitaVideo varchar(15) not null,
    AspectRatio varchar(10) not null,
    DimensioneFile double not null,
    LunghezzaVideo time not null,
    FormatoVideo varchar(5) not null,
    FormatoAudio varchar(5) not null,
    Film integer not null,
    
    foreign key(FormatoVideo) references FormatoVideo(ID),
    foreign key(FormatoAudio) references FormatoAudio(ID),
    foreign key(Film) references Film(ID)
);

drop table if exists FormatoAudio;
create table FormatoAudio(
	ID integer not null auto_increment primary key,
    MaxBitrate integer not null,
    Codec varchar(10) not null,
    Nome varchar(10) not null,
    DataRilascio date not null
);

drop table if exists FormatoVideo;
create table FormatoVideo(
	ID integer not null auto_increment primary key,
    Nome varchar(10) not null,
    Codec varchar(10) not null,
    FPS integer unsigned not null,
    DataRilascio date not null
);

drop table if exists Lingua;
create table Lingua(
	NomeLingua varchar(20) not null primary key
);

drop table if exists Audio;
create table Audio(
	IDFile integer not null,
    Lingua varchar(20) not null,
    
    primary key(IDFile, Lingua),
    foreign key(IDFile) references File(ID),
    foreign key(Lingua) references Lingua(NomeLingua)
);

drop table if exists Sottotitolo;
create table Sottotitolo(
	IDFile integer not null,
    Lingua varchar(20) not null,
    
    primary key(IDFile, Lingua),
    foreign key(IDFile) references File(ID),
    foreign key(Lingua) references Lingua(NomeLingua)
);
