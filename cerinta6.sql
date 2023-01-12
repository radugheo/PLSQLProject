--Pentru o echipa de fotbal careia i se va da ID-ul de la tastatura, salvati si afisati numele tuturor jucatorilor sai, iar pentru fiecare jucator sa se salveze si durata antrenamentului facut.

CREATE OR REPLACE PROCEDURE ex6(id_echipa_tast TEAM.ID_TEAM%TYPE) AS
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
            DBMS_OUTPUT.PUT_LINE(nume_jucatori(j) || ' - ' || antrenamente_jucatori(j));
        END LOOP;
END;

BEGIN
    ex6(1);
END;