-- Scrieti o functie care sa returneze id-ul patronului unei echipe date de la tastatura, daca aceasta are capacitatea stadionului > 20000.

CREATE OR REPLACE FUNCTION ex8(
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
        RAISE_APPLICATION_ERROR(-20000, 'Echipa cu id-ul ' || id_echipa || ' nu are capacitatea stadionului mai mare de 20000');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20002, 'Alta eroare');
END;

BEGIN
    DBMS_OUTPUT.PUT_LINE(ex8(2));
END;