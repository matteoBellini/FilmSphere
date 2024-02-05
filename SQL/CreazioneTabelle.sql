create table Film(
	ID integer not null primary key auto_increment,
    Titolo varchar(255) not null,
    Descrizione varchar(500) not null,
    Durata integer not null,
    AnnoDiProduzione integer not null,
    Genere varchar(25) not null,
    Recensioni integer default 0,
    NumRecensioni integer default 0,
    Critica integer default 0,
    PremiFilm integer default 0,
    PremiCineasta integer default 0,
    foreign key (Genere) references Genere(Nome)
);

create table Genere(
	Nome varchar(25) primary key not null
);

create table Cineasta(
	IdCineasta integer not null auto_increment primary key,
    Nome varchar(20) not null,
    Cognome varchar(20) not null,
    DataNascita date not null,
    LuogoNascita varchar(30)
);

create table Recitazione(
	IdCineasta integer,
    Film integer,
    NomePersonaggio varchar(30) not null,
    foreign key (IdCineasta) references Cineasta(IdCineasta),
    foreign key (Film) references Film(ID)
);

create table Regia(
	IdCineasta integer,
    Film integer,
    foreign key (IdCineasta) references Cineasta(IdCineasta),
    foreign key (Film) references Film(ID)
);

create table PremiCineasta(
	Id integer auto_increment primary key,
    Nome varchar(50)not null,
    Importanza integer not null,
    Categoria varchar(50) not null
);

create table PremiFilm(
	Id integer auto_increment primary key,
    Nome varchar(50)not null,
    Importanza integer not null,
    Categoria varchar(50) not null
);

create table Premiazione(
	IdCineasta integer,
    IdPremio integer,
    DataPremiazione date not null,
    foreign key (IdCineasta) references Cineasta(IdCineasta),
    foreign key (IdPremio) references PremiCineasta(Id)
);

create table Vincita(
	IdFilm integer,
    IdPremio integer,
    DataVincita date not null,
    foreign key (IdFilm) references Film(ID),
    foreign key (IdPremio) references PremiFilm(Id)
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
    RinnovoAutomatico tinyint(1) not null,
    TipoAbbonamento varchar(10),
    foreign key (TipoAbbonamento) references Abbonamento(Tipo)
);

create table Abbonamento(
	Tipo varchar(10) primary key,
    Durata integer not null,
    NoData tinyint(1) not null,
    NumeroDispositivi integer not null,
    RisoluzioneMassima varchar(10) not null,
    Prezzo double not null
);

create table Critico(
    CF varchar(16) primary key
)
