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


