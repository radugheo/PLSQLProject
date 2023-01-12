-- Creati un trigger care sa nu permita modificarea tabelelor daca utilizatorul nu este 'radu'
CREATE OR REPLACE TRIGGER trigger_user
    BEFORE CREATE OR DROP OR ALTER
    ON SCHEMA
BEGIN
    IF LOWER(USER) != LOWER('radu') THEN
        RAISE_APPLICATION_ERROR(-21000, 'Doar radu poate modifica tabelele!');
    END IF;
END;