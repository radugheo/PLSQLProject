CREATE OR REPLACE PROCEDURE ex7(
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