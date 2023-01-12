-- Creati un trigger LMD la nivel de linie care sa nu permita marirea bugetului de transfer al echipelor.

CREATE OR REPLACE TRIGGER trigger_buget
    BEFORE UPDATE OF TEAM_BUDGET
    ON TEAM
    FOR EACH ROW
BEGIN
    IF (:NEW.TEAM_BUDGET > :OLD.TEAM_BUDGET) THEN
        RAISE_APPLICATION_ERROR(-20102,  'Bugetul echipei nu poate fi marit.');
    END IF;
END;


UPDATE TEAM
SET TEAM_BUDGET = TEAM.TEAM_BUDGET + 5000000;
/