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

create table Genere(
	Nome varchar(25) primary key not null
);

create table Cineasta(
	IdCineasta integer not null auto_increment primary key,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    DataNascita date not null,
    LuogoNascita varchar(30) not null
);

create table Recitazione(
	IdCineasta integer,
    Film integer,
    NomePersonaggio varchar(30) not null,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(Film) references Film(ID)
);

create table Regia(
	IdCineasta integer,
    Film integer,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(Film) references Film(ID)
);

create table PremiCineasta(
	Id integer auto_increment primary key,
    Nome varchar(50)not null,
    Importanza integer unsigned not null,
    Categoria varchar(50) not null
);

create table PremiFilm(
	Id integer auto_increment primary key,
    Nome varchar(50)not null,
    Importanza integer unsigned not null,
    Categoria varchar(50) not null
);

create table Premiazione(
	IdCineasta integer,
    IdPremio integer,
    DataPremiazione date not null,
    foreign key(IdCineasta) references Cineasta(IdCineasta),
    foreign key(IdPremio) references PremiCineasta(Id)
);

create table Vincita(
	IdFilm integer,
    IdPremio integer,
    DataVincita date not null,
    foreign key(IdFilm) references Film(ID),
    foreign key(IdPremio) references PremiFilm(Id)
);

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
    foreign key(TipoAbbonamento) references Abbonamento(Tipo)
);

create table Abbonamento(
	Tipo varchar(10) primary key,
    Durata integer unsigned not null,
    NoData bit(1) not null,
    NumeroDispositivi integer unsigned not null,
    RisoluzioneMassima varchar(10) not null,
    Prezzo double unsigned not null
);

create table Critico(
    CF varchar(16) primary key,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    DataNascita date not null,
    Sesso varchar(1) not null,
    Azienda varchar(20) not null
);

create table Recensione(
	CFUtente varchar(16) not null,
    IDFilm integer not null,
    Testo varchar(500),
    Punteggio integer unsigned not null,
    
    primary key(CFUtente, IDFilm),
    foreign key(CFUtente) references Utente(CF),
    foreign key(IDFilm) references Film(ID)
);

create table Critica(
	CFUtente varchar(16) not null,
    IDFilm integer not null,
    Testo varchar(500),
    Punteggio integer unsigned not null,
    
    primary key(CFUtente, IDFilm),
    foreign key(CFUtente) references Utente(CF),
    foreign key(IDFilm) references Film(ID)
);

create table Carta(
	Numero varchar(16) not null primary key,
    CognomeTitolare varchar(20) not null,
    NomeTitolare varchar(20) not null,
    DataScadenza date not null,
    CVV varchar(3) not null,
    UtenteAssociato varchar(16) not null,
    
    foreign key(UtenteAssociato) references Utente(CF)
);

create table Fattura(
	Numero integer not null auto_increment primary key,
    DataEmissione date not null,
    Importo double not null,
    NumeroCarta varchar(16) not null,
    Utente varchar(16) not null,
    
    foreign key(NumeroCarta) references Carta(Numero),
    foreign key(Utente) references Utente(CF)
);

create table Dispositivo(
	IndirizzoMAC varchar(17) not null primary key,
    Hardware varchar(20) not null,
    Risoluzione varchar(10) not null,
    IndirizzoIP varchar(15) not null,
    InizioConnessione datetime,
    FineConnessione datetime,
    Utente varchar(16) not null,
    Paese varchar(20) not null,
    Latitudine varchar(30),
    Longitudine varchar(30),
    ServerConnesso varchar(15) not null,
    
    foreign key(Utente) references Utente(CF),
    foreign key(Paese) references Paese(Nome),
    foreign key(ServerConnesso) references Server(IndirizzoIP)
);

create table Paese(
	Nome varchar(20) not null primary key,
    NumeroAbitanti integer not null,
    IPRangeStart varchar(10) not null,
    IPRangeEnd varchar(10) not null
);

create table Produzione(
	IDFilm integer not null,
    Paese varchar(20) not null,
    
    primary key(IDFilm, Paese),
    foreign key(IDFilm) references Film(ID),
    foreign key(Paese) references Paese(Nome)
);

create table Restrizione(
	ID integer not null auto_increment,
    FormatoVideo varchar(5) not null,
    FormatoAudio varchar(5) not null
);

create table PaeseRestrizione(
	IDRestrizione integer not null,
    Paese varchar(20) not null,
    
    primary key(IDRestrizione, Paese),
    foreign key(IDRestrizione) references Restrizione(ID),
    foreign key(Paese) references Paese(Nome)
);

create table Server(
	IndirizzoIP varchar(15) not null primary key,
    Latitudine varchar(30) not null,
    Longitudine varchar(30) not null,
    CAPBanda integer not null,
    CAPTrasmissione integer not null,
    DimensioneCache integer not null,
    CaricoAttuale float not null,
    Paese varchar(20) not null,
    
    foreign key(Paese) references Paese(Nome)
);

create table PoP(
	IDFile integer not null,
    IPServer varchar(15) not null,
    
    primary key(IDFile, IPServer),
    foreign key(IDFile) references File(ID),
    foreign key(IPServer) references Server(IndirizzoIP)
);

create table Visualizzazione(
	IDFile integer not null,
    Dispositivo varchar(17) not null,
    MinutoCorrente time not null,
    
    primary key(IDFile, Dispositivo),
    foreign key(IDFile) references File(ID),
    foreign key(Dispositivo) references Dispositivo(IndirizzoMAC)
);

create table File(
	ID integer not null auto_increment primary key,
    Risoluzione varchar(10) not null,
    BitRate integer not null,
    QualitaAudio varchar(15) not null,
    QualitaVideo varchar(15) not null,
    AspectRatio varchar(10) not null,
    DimensioneFile integer not null,
    LunghezzaVideo time not null,
    FormatoVideo varchar(5) not null,
    FormatoAudio varchar(5) not null,
    Film integer not null,
    
    foreign key(FormatoVideo) references FormatoVideo(ID),
    foreign key(FormatoAudio) references FormatoAudio(ID),
    foreign key(Film) references Film(ID)
);

create table FormatoAudio(
	ID integer not null auto_increment primary key,
    MaxBitrate integer not null,
    Codec varchar(10) not null,
    Nome varchar(10) not null,
    DataRilascio date not null
);

create table FormatoVideo(
	ID integer not null auto_increment primary key,
    Nome varchar(10) not null,
    Codec varchar(10) not null,
    FPS integer not null,
    DataRilascio date not null
);

create table Lingua(
	NomeLingua varchar(20) not null primary key
);

create table Audio(
	IDFile integer not null,
    Lingua varchar(20) not null,
    
    primary key(IDFile, Lingua),
    foreign key(IDFile) references File(ID),
    foreign key(Lingua) references Lingua(NomeLingua)
);

create table Sottotitolo(
	ßIDFile integer not null,
    Lingua varchar(20) not null,
    
    primary key(IDFile, Lingua),
    foreign key(IDFile) references File(ID),
    foreign key(Lingua) references Lingua(NomeLingua)
);
