-- Afisati numele si varsta celui mai in varsta jucator care joaca la o echipa cu buget mai mare decat un buget dat de la tastatura, precum si stadionul si sponsorul aferenti echipei lui si orasul corespunzator.

CREATE OR REPLACE PROCEDURE ex9(
    p_buget TEAM.TEAM_BUDGET%TYPE
)
AS
    MISSING_PLAYER_NAME EXCEPTION;
    MISSING_PLAYER_AGE EXCEPTION;
    TYPE t_detalii_jucator IS RECORD
                              (
                                  t_nume_jucator   PLAYER.PLAYER_NAME%TYPE,
                                  t_varsta_jucator PLAYER.PLAYER_AGE%TYPE,
                                  t_stadion        STADIUM.ID_STADIUM%TYPE,
                                  t_oras           CITY.CITY_NAME%TYPE,
                                  t_sponsor        SPONSOR.SPONSOR_NAME%TYPE
                              );
    detalii_jucator t_detalii_jucator;
    TYPE tabel_jucatori IS TABLE OF t_detalii_jucator INDEX BY PLS_INTEGER;
    t_jucatori      tabel_jucatori;

 BEGIN
    SELECT p.player_name, p.player_age, s.id_stadium, c.city_name, sps.sponsor_name BULK COLLECT
    INTO t_jucatori
    FROM player p,
         team t,
         stadium s,
         city c,
         sponsor sps
    WHERE p.id_team = t.id_team
      AND t.id_team = s.id_team
      AND s.id_city = c.id_city
      AND t.id_sponsor = sps.id_sponsor
      AND p.player_age = (SELECT max(p1.player_age)
                          FROM player p1,
                               team t1
                          WHERE p1.id_team = t1.id_team
                            AND t1.team_budget > p_buget)
      AND t.team_budget > p_buget;

    FOR i IN t_jucatori.first..t_jucatori.last
        LOOP
            IF t_jucatori(i).t_nume_jucator IS NULL THEN
                raise MISSING_PLAYER_NAME;
            END IF;
            IF t_jucatori(i).t_varsta_jucator IS NULL THEN
                raise MISSING_PLAYER_AGE;
            END IF;
            dbms_output.put_line('Nume jucator: ' || t_jucatori(i).t_nume_jucator);
            dbms_output.put_line('Varsta jucator: ' || t_jucatori(i).t_varsta_jucator);
            dbms_output.put_line('Stadion: ' || t_jucatori(i).t_stadion);
            dbms_output.put_line('Oras: ' || t_jucatori(i).t_oras);
            dbms_output.put_line('Sponsor: ' || t_jucatori(i).t_sponsor);
        END LOOP;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20000, 'Nu exista ASemenea jucator.');
    WHEN TOO_MANY_ROWS THEN
        RAISE_APPLICATION_ERROR(-20001, 'Exista mai multi jucatori cu conditia data.');
    WHEN MISSING_PLAYER_NAME THEN
        RAISE_APPLICATION_ERROR(-20003, 'Jucatorul nu are nume.');
    WHEN MISSING_PLAYER_AGE THEN
        RAISE_APPLICATION_ERROR(-20004, 'Jucatorul nu are varsta.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Alta eroare!');
END;

BEGIN
    ex9(3000000);
END;