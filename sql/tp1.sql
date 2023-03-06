/*insert into match ( matchId , dateMatch, scorelocale , scorevisiteur ,joueur_local,joueur_visiteur)
select id ,
to_date(mdate, 'YYYY-MM-DD HH24:MI:SS'),
home_team_goal,
away_team_goal,
home_team_api_id,
away_team_api_id
from DATAL3.match;

insert into engager (equipeId ,joueurid,saisonid)
select distinct home_team_api_id, home_player_1 , (select saisonId from saison where libelle = season)
from DATAL3.match
where home_player_1 is not null;
set serveroutput on;
declare 
i integer :=1;
query varchar2(5000) := 'select distinct home_team_api_id , home_player_1, ( select saisonid from saison where libelle= season ) from datal3.match where home_player_1 is not null';
begin
    dbms_output.put_line('insert into engager ( equipeid ,joueurid,saisonid)');
    loop
        dbms_output.put_line(replace(query, 'player_1' , 'player_' || i ));
        dbms_output.put_line('union');
        dbms_output.put_line(replace(replace(query , 'player_1' , 'player_' || i ),'home','away'));
        exit when i = 11 ;
        dbms_output.put_line('union');
        i := i+1;
        end loop;
end;
select nom_ligue, sum(scorelocale + scorevisiteur)
from match,equipe,ligue,saison
where match.datematch between saison.datedeb and saison.datefin
and match.joueur_local = equipe.equipeid
and equipe.equipeid = ligue.ligueid
and saison.libelle = '2015/2016'
group by ligue.ligueid, ligue.nom_ligue
order by sum(scorelocale + scorevisiteur ) desc ;*/
/*drop table ligue cascade CONSTRAINTS;*/
insert into ligue 
select l.id , l.name , c.name
from DATAL3.league l , DATAL3.country c
where l.country_id = c.id;

insert into ligue
select l.id, l.name, c.name
from DATAL3.league l , DATAL3.country c 
where l.country_id = c.id;

select ligue.nom_ligue, sum(scorelocale + scorevisiteur)
from ligue, match , equipe , saison
where match.datematch between saison.datedeb and saison.datefin
and match.joueur_local = equipe.equipeid
and equipe.ligueid = ligue.ligueid
and saison.libelle = '2015/2016'
group by ligue.ligueid, ligue.nom_ligue
ORDER BY SUM(scorelocale + scorevisiteur)desc;

        