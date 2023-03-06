/* -------------------------------------PARTIE A -----------------------------------------------------------------------  */
CREATE TABLE LIGUE (
    ligueId INT,
    nom_ligue VARCHAR2(100),
    pays VARCHAR2(100),
    CONSTRAINT PK_Ligue PRIMARY KEY (ligueId)
);

CREATE TABLE Equipe (
    equipeId INT,
    nom_equipe VARCHAR2(100),
    nom_court VARCHAR2(3),
    ligueId INT,
    CONSTRAINT PK_Equipe PRIMARY KEY (equipeId),
    CONSTRAINT FK_Equipe_Ligue FOREIGN KEY (ligueId) REFERENCES Ligue(ligueId)
);

CREATE TABLE Joueur (
    joueurId INT,
    nom_joueur VARCHAR2(100),
    prenom_joueur VARCHAR2(100),
    dateNaissance date,
    taille number(3,2),
    poids number(5,2),
    CONSTRAINT PK_Joueur PRIMARY KEY (joueurId) 
);

CREATE TABLE Match (
    matchId int,
    dateMatch date,
    scoreLocale number(2),
    scoreVisiteur number(2),
    equipeLocale int,
    equipeVisiteur int,
    CONSTRAINT PK_Match PRIMARY KEY (matchId),
    CONSTRAINT FK_Match_Equipe_1 FOREIGN KEY(equipeLocale) REFERENCES Equipe(equipeId),
    CONSTRAINT FK_Match_Equipe_2 FOREIGN KEY(equipeVisiteur) REFERENCES Equipe(equipeId)
);

CREATE TABLE Saison ( 
    saisonId int,
    libelle VARCHAR2(100),
    dateDeb date,
    dateFin date,
    CONSTRAINT PK_Saison PRIMARY KEY (saisonId)
);

CREATE TABLE Engager (
    equipeId int,
    joueurId int,
    saisonId int,
    CONSTRAINT PK_Engager PRIMARY KEY (equipeId , joueurId , saisonId),
    CONSTRAINT FK_Engager_Equipe FOREIGN KEY(equipeId) REFERENCES Equipe(equipeId),
    CONSTRAINT FK_Engager_joueur FOREIGN KEY (joueurId) REFERENCES Joueur(joueurId),
    CONSTRAINT FK_Engager_Saison FOREIGN KEY(saisonId) REFERENCES Saison(saisonId)
);

CREATE TABLE Marquer (
    joueurId int,
    matchId int,
    minute number(3),
    CONSTRAINT PK_Marquer PRIMARY KEY (joueurId,matchId,minute),
    CONSTRAINT FK_Marquer_Joueur FOREIGN KEY(joueurId) REFERENCES Joueur(joueurId),
    CONSTRAINT FK_Marquer_Match FOREIGN KEY(matchId) REFERENCES Match(matchId)
);

alter table Marquer add seconde number(2);
alter table ligue modify nom_ligue varchar2(150);

/* ----------------------------------------PARTIE C--------------------------------------------------------------------  */

insert into ligue
select l.id,l.name,c.name
from DATAL3.league l , DATAL3.country c
where l.country_id = c.id;

insert into equipe
select DISTINCT t.team_api_id, t.team_long_name , team_short_name , m.league_id
from DATAL3.team t , DATAL3.match m
where m.home_team_api_id = t.team_api_id ;

DROP SEQUENCE seq_saison;
CREATE sequence seq_saison;
CREATE OR REPLACE trigger trig_seq_saison
before insert on saison
for each row
begin
select seq_saison.nextval into :new.saisonId from dual;
end;
/

insert into saison (libelle,dateDeb,dateFin)
select distinct season,
    to_date('01/08' || substr(season, 1 ,4),'DD/MM/YYYY'),
    to_date('30/06/' || substr(season , 6 , 4 ),'DD/MM/YYYY')
from DATAL3.match;

insert into joueur (joueurId , nom_joueur, prenom_joueur,dateNaissance , taille ,poids )
select p.player_api_id,
    substr(p.player_name,instr(p.player_name, ' ', 1) + 1),
    substr(p.player_name, 1 , instr(p.player_name , ' ', 1 ) -1),
    to_date(p.birthday, 'YYYY-MM-DD HH24:MI:SS'),
    p.height/100,
    p.weight/2.2046
from DATAL3.player p;

insert into match ( matchId , dateMatch, scorelocale , scorevisiteur ,equipeLocale,equipeVisiteur)
select id ,
    to_date(mdate, 'YYYY-MM-DD HH24:MI:SS'),
    home_team_goal,
    away_team_goal,
    home_team_api_id,
    away_team_api_id
from DATAL3.match;
    
/*DELETE FROM engager ;

INSERT into engager (equipeId , joueurId ,saisonId )
select distinct home_team_api_id, home_player_1 , (select saisonId from saison where libelle = season ) 
from DATAL3.match 
where home_player_1 is not null ;

set serveroutput on;
declare 
    i integer :=1;
    query varchar2(5000) := 'select distinct home_team_api_id , home_player_1 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_1 is not null';
    begin
        dbms_output.put_line('insert into engager ( equipeId ,joueurId,saisonId)');
        loop
            dbms_output.put_line(replace(query, 'player_1' , 'player_' || i ));
            dbms_output.put_line('union');
            dbms_output.put_line(replace(replace(query , 'player_1' , 'player_' || i ),'home','away'));
            exit when i = 11 ;
            dbms_output.put_line('union');
            i := i+1;
        end loop;
    end;
insert into engager ( equipeId ,joueurId,saisonId)
select distinct home_team_api_id , home_player_1 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_1 is not null
union
select distinct away_team_api_id , away_player_1 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_1 is not null
union
select distinct home_team_api_id , home_player_2 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_2 is not null
union
select distinct away_team_api_id , away_player_2 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_2 is not null
union
select distinct home_team_api_id , home_player_3 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_3 is not null
union
select distinct away_team_api_id , away_player_3 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_3 is not null
union
select distinct home_team_api_id , home_player_4 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_4 is not null
union
select distinct away_team_api_id , away_player_4 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_4 is not null
union
select distinct home_team_api_id , home_player_5 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_5 is not null
union
select distinct away_team_api_id , away_player_5 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_5 is not null
union
select distinct home_team_api_id , home_player_6 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_6 is not null
union
select distinct away_team_api_id , away_player_6 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_6 is not null
union
select distinct home_team_api_id , home_player_7 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_7 is not null
union
select distinct away_team_api_id , away_player_7 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_7 is not null
union
select distinct home_team_api_id , home_player_8 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_8 is not null
union
select distinct away_team_api_id , away_player_8 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_8 is not null
union
select distinct home_team_api_id , home_player_9 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_9 is not null
union
select distinct away_team_api_id , away_player_9 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_9 is not null
union
select distinct home_team_api_id , home_player_10 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_10 is not null
union
select distinct away_team_api_id , away_player_10 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_10 is not null
union
select distinct home_team_api_id , home_player_11 , (select saisonId from saison where libelle = season) from DATAL3.match where home_player_11 is not null
union
select distinct away_team_api_id , away_player_11 , (select saisonId from saison where libelle = season) from DATAL3.match where away_player_11 is not null;*/
/* -----------------------------------PARTIE E-------------------------------------------------------------------*/
select ligue.nom_ligue, sum(scorelocale + scorevisiteur)
from ligue, match , equipe , saison
where match.datematch between saison.datedeb and saison.datefin
and match.equipelocale = equipe.equipeid
and equipe.ligueid = ligue.ligueid
and saison.libelle = '2015/2016'
group by ligue.ligueid, ligue.nom_ligue
ORDER BY SUM(scorelocale + scorevisiteur)desc;

/* ----------*******************   TP    2       ****************************------------------------------------------------------------------------------------------------*/

CREATE OR REPLACE VIEW Moy_vue AS 
select ligue.nom_ligue, sum(scorelocale + scorevisiteur) as moyenne_ANNEE ,  sum(scorelocale + scorevisiteur)/38 as moyenneBUT_JOUR 
from ligue, match , equipe , saison
where match.datematch between saison.datedeb and saison.datefin
and match.equipelocale = equipe.equipeid
and equipe.ligueid = ligue.ligueid
and saison.libelle = '2015/2016'
group by ligue.ligueid, ligue.nom_ligue
ORDER BY SUM(scorelocale + scorevisiteur)desc;

