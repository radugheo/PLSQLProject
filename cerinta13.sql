CREATE OR REPLACE PACKAGE Proiect AS
    PROCEDURE ex6(id_echipa_tast TEAM.ID_TEAM%TYPE);
    PROCEDURE ex7(
        buget_minim TEAM.TEAM_BUDGET%TYPE,
        varsta_minima PLAYER.PLAYER_AGE%TYPE
    );
    FUNCTION ex8(
        id_echipa TEAM.ID_TEAM%TYPE
    )
    RETURN VARCHAR;
    PROCEDURE ex9(
        p_buget TEAM.TEAM_BUDGET%TYPE
    );
END Proiect;

CREATE OR REPLACE PACKAGE BODY Proiect AS
    PROCEDURE ex6(id_echipa_tast TEAM.ID_TEAM%TYPE) AS
        TYPE tablou_indexat IS TABLE OF PLAYER.PLAYER_NAME%TYPE INDEX BY PLS_INTEGER;
        nume_jucatori         tablou_indexat;
        TYPE tablou_imbricat IS TABLE OF TRAINING.TRAINING_DURATION%TYPE;
        antrenamente_jucatori tablou_imbricat := tablou_imbricat();
        i                     NUMBER;
        id_echipa_jucatori    PLAYER.ID_TEAM%TYPE;
        id_jucator            PLAYER.ID_PLAYER%TYPE;
        id_jucator_loop       PLAYER.ID_PLAYER%TYPE;
        nume_jucator          PLAYER.PLAYER_NAME%TYPE;
        nume_echipa           TEAM.TEAM_NAME%TYPE;
        antrenament_jucator   TRAINING.TRAINING_DURATION%TYPE;
        numar_jucatori        NUMBER;
     BEGIN
        i := 0;
        SELECT count(*) INTO numar_jucatori FROM PLAYER;
        SELECT TEAM_NAME INTO nume_echipa FROM TEAM WHERE ID_TEAM = id_echipa_tast;
        FOR id_jucator_loop IN 2..numar_jucatori
            LOOP
                SELECT ID_TEAM INTO id_echipa_jucatori FROM PLAYER WHERE ID_PLAYER = id_jucator_loop;
                IF id_echipa_jucatori = id_echipa_tast THEN
                    i := i + 1;
                    SELECT PLAYER_NAME, ID_PLAYER
                    INTO nume_jucator, id_jucator
                    FROM Player
                    WHERE ID_PLAYER = id_jucator_loop;
                    nume_jucatori(i) := nume_jucator;
                    antrenamente_jucatori.extEND;
                    SELECT TRAINING_DURATION
                    INTO antrenament_jucator
                    FROM TRAINING
                    WHERE ID_TRAINING = (SELECT ID_TRAINING FROM TRAINS WHERE ID_PLAYER = id_jucator);
                    antrenamente_jucatori(i) := antrenament_jucator;
                END IF;
            END LOOP;
        DBMS_OUTPUT.PUT_LINE('Echipa ' || nume_echipa || ' are urmatorii jucatori:');
        FOR j IN 1..nume_jucatori.COUNT
            LOOP
                DBMS_OUTPUT.PUT_LINE(nume_jucatori(j) || ' care a efectuat un antrenament de ' || antrenamente_jucatori(j) || ' ore.');
            END LOOP;
    END;

    PROCEDURE ex7(
        buget_minim TEAM.TEAM_BUDGET%TYPE,
        varsta_minima PLAYER.PLAYER_AGE%TYPE
    )
    AS
        CURSOR echipe IS
            SELECT ID_TEAM
            FROM TEAM
            WHERE TEAM_BUDGET >= buget_minim;
        CURSOR jucatori (varsta PLAYER.PLAYER_AGE%TYPE, echipa_jucator TEAM.ID_TEAM%TYPE) IS
            SELECT PLAYER_NAME
            FROM PLAYER
            WHERE PLAYER_AGE >= varsta
              AND ID_TEAM = echipa_jucator;
        jucatori_sol PLAYER.PLAYER_NAME%TYPE;
        echipa       TEAM.TEAM_NAME%TYPE;

     BEGIN
        DBMS_OUTPUT.PUT_LINE('Echipele cu bugetul de minim ' || buget_minim || ' sunt: ');
        FOR echipa IN echipe
            LOOP
                OPEN jucatori(varsta_minima, echipa.ID_TEAM);
                FETCH jucatori INTO jucatori_sol;
                WHILE jucatori%FOUND
                    LOOP
                        DBMS_OUTPUT.PUT_LINE('Jucatorul cu varsta de minim ' || varsta_minima || ' este: ' ||
                                             jucatori_sol);
                        FETCH jucatori INTO jucatori_sol;
                    END LOOP;
                DBMS_OUTPUT.PUT_LINE('------------------------');
                CLOSE jucatori;
                DBMS_OUTPUT.PUT_LINE('Echipa: ' || echipa.ID_TEAM);
                DBMS_OUTPUT.NEW_LINE;
            END LOOP;
    END;

    FUNCTION ex8(
        id_echipa TEAM.ID_TEAM%TYPE
    )
        RETURN VARCHAR is
        nume_patron OWNER.OWNER_NAME%TYPE;
        id_patron   OWNER.ID_OWNER%TYPE;
     BEGIN
        SELECT id_owner
        INTO id_patron
        FROM OWNER
        WHERE id_owner = (SELECT id_owner
                          FROM TEAM
                                   JOIN STADIUM ON TEAM.ID_TEAM = STADIUM.ID_TEAM
                          WHERE TEAM.ID_TEAM = id_echipa
                            AND STADIUM.STADIUM_CAPACITY > 20000);
        SELECT owner_name
        INTO nume_patron
        FROM OWNER
        WHERE id_owner = id_patron;
        RETURN nume_patron;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20000,
                                    'Echipa cu id-ul ' || id_echipa ||
                                    ' nu are capacitatea stadionului mai mare de 20000');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Alta eroare');
    END;

    PROCEDURE ex9(
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

END Proiect;
/

 BEGIN
    Proiect.ex6(1);
    Proiect.ex7(3000000, 28);
    dbms_output.put_line(Proiect.ex8(2));
    Proiect.ex9(3500000);
END;