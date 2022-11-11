///////////////////////////////////////// * \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
				    				TD6 REQUETES
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

CREATE OR REPLACE PROCEDURE ps_insert_demandeur(pnomdemandeur DEMANDEUR.nomdemandeur%TYPE,
                                        pprenomdemandeur DEMANDEUR.prenomdemandeur%TYPE, pemail DEMANDEUR.email%TYPE,
                                        ptypedemandeur DEMANDEUR.typedemandeur%TYPE, prue DEMANDEUR.rue%TYPE, pcp DEMANDEUR.cp%TYPE,
                                        pville DEMANDEUR.ville%TYPE, ptelfixe DEMANDEUR.telfixe%TYPE, pentreprise DEMANDEUR.entreprise%TYPE,pnumbureau DEMANDEUR.numbureau%TYPE, pmobile DEMANDEUR.mobile%TYPE)
AS
$$
DECLARE
    v_state TEXT;
    v_message TEXT;
    v_column TEXT;
    v_constraint TEXT;
    v_detail TEXT;
    v_context TEXT;
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
    END IF;
    INSERT INTO DEMANDEUR (IDDEMANDEUR, NOMDEMANDEUR, PRENOMDEMANDEUR, EMAIL, TYPEDEMANDEUR, RUE, CP, VILLE, TELFIXE, ENTREPRISE,NUMBUREAU, MOBILE) 
        VALUES (nextval('SEQ_DEMANDEUR'), pnomdemandeur, pprenomdemandeur, pemail, ptypedemandeur, prue, pcp,
            pville,ptelfixe,pentreprise, pnumbureau, pmobile);
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_constraint = CONSTRAINT_NAME;
            -- C'est sensible à la casse
            IF v_constraint = 'ck_demandeur_mobile' THEN
                RAISE EXCEPTION 'Impossible d''insérer, n°mobile non valide';
            ELSIF v_constraint = 'ck_demandeur_type' THEN
                RAISE EXCEPTION 'Impossible d''insérer le demandeur doit être vacataire ou permanent';
            ELSE
                -- Pour les autres contraintes CHECK éventuellement ajoutées par la suite
                RAISE EXCEPTION 'Impossible d''insérer, contrainte check violée nommée %', v_constraint; 
            END IF;
        WHEN unique_violation THEN
            GET STACKED DIAGNOSTICS v_constraint = CONSTRAINT_NAME;
            IF v_constraint = 'uq_demandeur' THEN
                RAISE EXCEPTION 'Impossible d''insérer le demandeur. Doublon sur nom, prénom et téléphone fixe';
            ELSE
                RAISE EXCEPTION 'Impossible d''insérer, contrainte d''unicité violée nommée %', v_constraint;
            END IF;
        WHEN raise_exception THEN
            GET STACKED DIAGNOSTICS v_message = MESSAGE_TEXT;
            RAISE EXCEPTION '%', v_message;
        WHEN others THEN
            GET STACKED DIAGNOSTICS
                v_state = RETURNED_SQLSTATE,
                v_column = COLUMN_NAME,
                v_constraint = CONSTRAINT_NAME;
            RAISE EXCEPTION 'Impossible d''insérer. Violation de la contrainte : code erreur : %, champ : %, contrainte violée : %', v_state, v_column, v_constraint;
END;
$$ LANGUAGE 'plpgsql'

/* ================================================================================= */



/* ================================================================================= */
/* # Question 2                                                                      */
/* ================================================================================= */

CREATE OR REPLACE PROCEDURE ps_update_demandeur(pidemandeur DEMANDEUR.iddemandeur%TYPE,pnomdemandeur DEMANDEUR.nomdemandeur%TYPE,
                                        pprenomdemandeur DEMANDEUR.prenomdemandeur%TYPE, pemail DEMANDEUR.email%TYPE,
                                        ptypedemandeur DEMANDEUR.typedemandeur%TYPE, prue DEMANDEUR.rue%TYPE, pcp DEMANDEUR.cp%TYPE,
                                        pville DEMANDEUR.ville%TYPE, ptelfixe DEMANDEUR.telfixe%TYPE, pentreprise DEMANDEUR.entreprise%TYPE,pnumbureau DEMANDEUR.numbureau%TYPE, pmobile DEMANDEUR.mobile%TYPE)

AS
$$
DECLARE
    v_state TEXT;
    v_message TEXT;
    v_column TEXT;
    v_constraint TEXT;
    v_detail TEXT;
    v_context TEXT;
BEGIN
    -- PROF PERMANENT
    IF ptypedemandeur = 'Permanent' THEN
        IF pnumbureau = '' OR pnumbureau is null THEN
            -- PAS DE NUM DE BUREAU
            RAISE EXCEPTION 'ERROR: Impossible de MAJ le permanent, son n° de bureau est obligatoire'; 
        END IF;
    
    -- PROF VACATAIRE
    ELSIF ptypedemandeur = 'Vacataire' THEN
        -- ADRESSE
        IF (prue = '' OR prue is null) OR (pcp = '' OR pcp is null) OR (pville = '' OR pville is null) THEN
            RAISE EXCEPTION 'ERROR: Impossible de MAJ le vacataire, son adresse (rue, CP, ville) est obligatoire'; 
        -- TELEPHONE
        ELSIF ptelfixe = '' OR ptelfixe is null THEN
			RAISE EXCEPTION 'ERROR: Impossible de MAJ le vacataire, le n° de téléphone fixe est obligatoire';
        -- ENTREPRISE
		ELSIF pentreprise = '' OR pentreprise is null THEN
            RAISE EXCEPTION 'ERROR: Impossible de MAJ le vacataire, l''entrepise est obligatoire';           
		END IF;
    END IF;
    UPDATE DEMANDEUR
    SET nomdemandeur = pnomdemandeur, prenomdemandeur = pprenomdemandeur, email = pemail, typedemandeur = ptypedemandeur, 
        rue = prue, cp = pcp, ville = pville,telfixe = ptelfixe,entreprise = pentreprise, numbureau = pnumbureau, mobile = pmobile
    WHERE iddemandeur = pidemandeur;
    EXCEPTION
        WHEN check_violation THEN
            GET STACKED DIAGNOSTICS v_constraint = CONSTRAINT_NAME;
            -- C'est sensible à la casse
            IF v_constraint = 'ck_demandeur_mobile' THEN
                RAISE EXCEPTION 'Impossible de MAJ, n°mobile non valide';
            ELSIF v_constraint = 'ck_demandeur_type' THEN
                RAISE EXCEPTION 'Impossible de MAJ le demandeur doit être vacataire ou permanent';
            ELSE
                -- Pour les autres contraintes CHECK éventuellement ajoutées par la suite
                RAISE EXCEPTION 'Impossible de MAJ, contrainte check violée nommée %', v_constraint; 
            END IF;
        WHEN unique_violation THEN
            GET STACKED DIAGNOSTICS v_constraint = CONSTRAINT_NAME;
            IF v_constraint = 'uq_demandeur' THEN
                RAISE EXCEPTION 'Impossible de MAJ le demandeur. Doublon sur nom, prénom et téléphone fixe';
            ELSE
                RAISE EXCEPTION 'Impossible de MAJ, contrainte d''unicité violée nommée %', v_constraint;
            END IF;
        WHEN raise_exception THEN
            GET STACKED DIAGNOSTICS v_message = MESSAGE_TEXT;
            RAISE EXCEPTION '%', v_message;
        WHEN others THEN
            GET STACKED DIAGNOSTICS
                v_state = RETURNED_SQLSTATE,
                v_column = COLUMN_NAME,
                v_constraint = CONSTRAINT_NAME;
            RAISE EXCEPTION 'Impossible de MAJ. Violation de la contrainte : code erreur : %, champ : %, contrainte violée : %', v_state, v_column, v_constraint;
END;
$$ LANGUAGE 'plpgsql'

/* ================================================================================= */

/* ================================================================================= */
/* # Question 3                                                                      */
/* ================================================================================= */

CREATE OR REPLACE PROCEDURE ps_suppr_demandeur(pidemandeur DEMANDEUR.iddemandeur%TYPE)
AS 
$$
DECLARE
    vNbvm vm%rowtype;
BEGIN
    SELECT COUNT(*) INTO STRICT vNbvm FROM VM WHERE iddemandeur = pidemandeur;
    DELETE FROM DEMANDEUR WHERE iddemandeur = pidemandeur;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE EXCEPTION 'Demandeur inconnu';
        WHEN TOO_MANY_ROWS THEN
            RAISE EXCEPTION 'Impossible de supprimer le demandeur car des enregistrements liés existent';
END;
$$ LANGUAGE 'plpgsql'

/* ================================================================================= */