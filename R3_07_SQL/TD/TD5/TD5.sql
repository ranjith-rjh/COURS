///////////////////////////////////////// * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
				    				TD5 REQUETES
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ * /////////////////////////////////////

|-------------------------------------------------------------------------------|


*********************************************************************************
				 @NO COPYRIGHT, AUTHOR : APPASSAMY Ranjith 
				 __________                    __.__  __  .__     
				 \______   \_____    ____     |__|__|/  |_|  |__  
				  |       _/\__  \  /    \    |  |  \   __\  |  \ 
				  |    |   \ / __ \|   |  \   |  |  ||  | |   Y  \
				  |____|_  /(____  /___|  /\__|  |__||__| |___|  /
						 \/      \/     \/\______|             \/ 

*********************************************************************************

/* ================================================================================= */
/* # Question 1                                                                      */
/* ================================================================================= */

--  LOOP 
DO
$$
DECLARE
	i INTEGER;
	vTypeDemandeur DEMANDEUR.TypeDemandeur%type;
	vMail DEMANDEUR.Email%type;
BEGIN
	i := 1;
	LOOP
        IF i%2 = 0 THEN
            vTypeDemandeur := 'Permanent';
            vMail = '@gmail.com';
        ELSE 
            vTypeDemandeur := 'Vacataire';
            vMail = '@univ-smb.fr';
        END IF;

        INSERT INTO DEMANDEUR (iddemandeur, nomdemandeur, prenomdemandeur, email, typedemandeur) 
            VALUES (nextval('SEQ_DEMANDEUR'), 'nom' || i, 'prenom' || i, 'prenom' || i || '.nom' || i || 'vMail', vTypeDemandeur);
        i := i+1 ;
        EXIT WHEN i > 100 ;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql'

--  WHILE 

DO
$$
DECLARE
	i INTEGER;
	vTypeDemandeur DEMANDEUR.TypeDemandeur%type;
	vMail DEMANDEUR.Email%type;
BEGIN
	i := 101;
	
    WHILE i <= 200 LOOP
        IF i%2 = 0 THEN
            vTypeDemandeur := 'Permanent';
            vMail = '@gmail.com';
        ELSE 
            vTypeDemandeur := 'Vacataire';
            vMail = '@univ-smb.fr';
        END IF;
        INSERT INTO DEMANDEUR (iddemandeur, nomdemandeur, prenomdemandeur, email, typedemandeur) 
            VALUES (nextval('SEQ_DEMANDEUR'), 'nom' || i, 'prenom' || i, 'prenom' || i || '.nom' || i || 'vMail', vTypeDemandeur);
        i := i+1 ;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql'

--   FOR  

DO
$$
DECLARE
	i INTEGER;
	vTypeDemandeur DEMANDEUR.TypeDemandeur%type;
	vMail DEMANDEUR.Email%type;
BEGIN
	
    FOR i IN 201 .. 300 LOOP
        IF i%2 = 0 THEN
            vTypeDemandeur := 'Permanent';
            vMail = '@gmail.com';
        ELSE 
            vTypeDemandeur := 'Vacataire';
            vMail = '@univ-smb.fr';
        END IF;
        INSERT INTO DEMANDEUR (iddemandeur, nomdemandeur, prenomdemandeur, email, typedemandeur) 
            VALUES (nextval('SEQ_DEMANDEUR'), 'nom' || i, 'prenom' || i, 'prenom' || i || '.nom' || i || 'vMail', vTypeDemandeur);
	END LOOP;
END;
$$ LANGUAGE 'plpgsql'

/* ================================================================================= */



/* ================================================================================= */
/* # Question 2                                                                      */
/* ================================================================================= */

-- ATTENTION A L''ESPACE
-- EXECUTE ==> CREATE && DROP
-- EXECUTE ==> CONCATENATION

DO
$$
DECLARE
    vIndexSequence LOGICIEL.idlogiciel%type;
BEGIN
    SELECT MAX(idlogiciel) FROM LOGICIEL INTO STRICT vIndexSequence;
    EXECUTE 'DROP SEQUENCE if exists vIndexSequence';
    EXECUTE 'CREATE SEQUENCE vIndexSequence START WITH ' || vIndexSequence+1;
END;
$$ LANGUAGE 'plpgsql'

/* ================================================================================= */



/* ================================================================================= */
/* # Question 3                                                                      */
/* ================================================================================= */

--  ------1

DO
$$
DECLARE
    i INTEGER;
    indexLogiciel INTEGER;
BEGIN
    FOR i IN 1 .. 20 LOOP
        indexLogiciel := nextval('vIndexSequence');
        INSERT INTO LOGICIEL VALUES (indexLogiciel, 'Odoo ' || indexLogiciel-43);
	END LOOP;
END;
$$ LANGUAGE 'plpgsql'

-- ------2

DO
$$
DECLARE
    i INTEGER;
    indexLogiciel INTEGER;
BEGIN
    FOR i IN 16 .. 35 LOOP
        INSERT INTO LOGICIEL VALUES (nextval('vIndexSequence'), 'Odoo ' || i);
	END LOOP;
    INSERT INTO COMPATIBILITE(idlogiciel, idos)
        SELECT idlogiciel, idos 
        FROM LOGICIEL 
            CROSS JOIN OS
        WHERE nomlogiciel LIKE 'Odoo%' and nomlogiciel not in('Odoo 8', 'Odoo 10');
END;
$$ LANGUAGE 'plpgsql'

/* ================================================================================= */



/* ================================================================================= */
/* # Question 4                                                                      */
/* ================================================================================= */
CREATE OR REPLACE PROCEDURE ps_insert_demandeur(pnomdemandeur DEMANDEUR.nomdemandeur%TYPE,
                                        pprenomdemandeur DEMANDEUR.prenomdemandeur%TYPE, pemail DEMANDEUR.email%TYPE,
                                        ptypedemandeur DEMANDEUR.typedemandeur%TYPE, prue DEMANDEUR.rue%TYPE, pcp DEMANDEUR.cp%TYPE,
                                        pville DEMANDEUR.ville%TYPE, ptelfixe DEMANDEUR.telfixe%TYPE, pentreprise DEMANDEUR.entreprise%TYPE,pnumbureau DEMANDEUR.numbureau%TYPE, pmobile DEMANDEUR.mobile%TYPE)
AS
$$
DECLARE
BEGIN
    -- PROF PERMANENT
    IF ptypedemandeur = 'Permanent' THEN
        IF pnumbureau = '' OR pnumbureau is null THEN
            -- PAS DE NUM DE BUREAU
            RAISE EXCEPTION 'ERROR: Impossible d''insérer le permanent, son n° de bureau est obligatoire'; 
        END IF;
    
    -- PROF VACATAIRE
    ELSIF ptypedemandeur = 'Vacataire' THEN
        -- ADRESSE
        IF (prue = '' OR prue is null) OR (pcp = '' OR pcp is null) OR (pville = '' OR pville is null) THEN
            RAISE EXCEPTION 'ERROR: Impossible d''insérer le vacataire, son adresse (rue, CP, ville) est obligatoire'; 
        -- TELEPHONE
        ELSIF ptelfixe = '' OR ptelfixe is null THEN
			RAISE EXCEPTION 'ERROR: Impossible d''insérer le vacataire, le n° de téléphone fixe est obligatoire';
        -- ENTREPRISE
		ELSIF pentreprise = '' OR pentreprise is null THEN
            RAISE EXCEPTION 'ERROR: Impossible d''insérer le vacataire, l''entrepise est obligatoire';           
		END IF;
    ELSE 
        RAISE EXCEPTION 'ERROR: Le demandeur doit être vacataire ou permanent';
    END IF;
    INSERT INTO DEMANDEUR (IDDEMANDEUR, NOMDEMANDEUR, PRENOMDEMANDEUR, EMAIL, TYPEDEMANDEUR, RUE, CP, VILLE, TELFIXE, ENTREPRISE,NUMBUREAU, MOBILE) 
        VALUES (nextval('SEQ_DEMANDEUR'), pnomdemandeur, pprenomdemandeur, pemail, ptypedemandeur, prue, pcp,
            pville,ptelfixe,pentreprise, pnumbureau, pmobile);

END;
$$ LANGUAGE 'plpgsql'

/* ================================================================================= */



/* ================================================================================= */
/* # Question 5                                                                      */
/* ================================================================================= */
CREATE OR REPLACE PROCEDURE ps_update_demandeur(pidemandeur DEMANDEUR.iddemandeur%TYPE,pnomdemandeur DEMANDEUR.nomdemandeur%TYPE,
                                        pprenomdemandeur DEMANDEUR.prenomdemandeur%TYPE, pemail DEMANDEUR.email%TYPE,
                                        ptypedemandeur DEMANDEUR.typedemandeur%TYPE, prue DEMANDEUR.rue%TYPE, pcp DEMANDEUR.cp%TYPE,
                                        pville DEMANDEUR.ville%TYPE, ptelfixe DEMANDEUR.telfixe%TYPE, pentreprise DEMANDEUR.entreprise%TYPE,pnumbureau DEMANDEUR.numbureau%TYPE, pmobile DEMANDEUR.mobile%TYPE)
AS
$$
DECLARE
BEGIN
    -- PROF PERMANENT
    IF ptypedemandeur = 'Permanent' THEN
        IF pnumbureau = '' OR pnumbureau is null THEN
            -- PAS DE NUM DE BUREAU
            RAISE EXCEPTION 'ERROR: Impossible d''insérer le permanent, son n° de bureau est obligatoire'; 
        END IF;
    
    -- PROF VACATAIRE
    ELSIF ptypedemandeur = 'Vacataire' THEN
        -- ADRESSE
        IF (prue = '' OR prue is null) OR (pcp = '' OR pcp is null) OR (pville = '' OR pville is null) THEN
            RAISE EXCEPTION 'ERROR: Impossible d''insérer le vacataire, son adresse (rue, CP, ville) est obligatoire'; 
        -- TELEPHONE
        ELSIF ptelfixe = '' OR ptelfixe is null THEN
			RAISE EXCEPTION 'ERROR: Impossible d''insérer le vacataire, le n° de téléphone fixe est obligatoire';
        -- ENTREPRISE
		ELSIF pentreprise = '' OR pentreprise is null THEN
            RAISE EXCEPTION 'ERROR: Impossible d''insérer le vacataire, l''entrepise est obligatoire';           
		END IF;
    ELSE 
        RAISE EXCEPTION 'ERROR: Le demandeur doit être vacataire ou permanent';
    END IF;
    UPDATE DEMANDEUR
    SET nomdemandeur = pnomdemandeur, prenomdemandeur = pprenomdemandeur, email = pemail, typedemandeur = ptypedemandeur, 
        rue = prue, cp = pcp, ville = pville,telfixe = ptelfixe,entreprise = pentreprise, numbureau = pnumbureau, mobile = pmobile
    WHERE iddemandeur = pidemandeur;
END;
$$ LANGUAGE 'plpgsql'

/* ================================================================================= */