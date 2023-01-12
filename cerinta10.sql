-- Creati un trigger LMD la nivel de comanda care sa nu permita inserarea a mai mult de 11 jucatori

CREATE OR REPLACE TRIGGER trigger_jucatori
    BEFORE INSERT
    ON player
DECLARE
    v_contor INT;
BEGIN
    SELECT count(id_player) into v_contor from player;
    IF v_contor >= 11 THEN
        RAISE_APPLICATION_ERROR(-20001, 'S-a incercat inserarea a mai mult de 11 jucatori.');
    END IF;
END;
