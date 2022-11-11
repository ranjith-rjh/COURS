-- Q1
SELECT t.typeos, os.nomos, COUNT(vm.idvm) AS "nb VMs"
FROM vm
  JOIN os ON vm.idos=os.idos
  JOIN typeos t ON os.idtypeos=t.idtypeos
GROUP BY ROLLUP(t.typeos, os.nomos)
ORDER BY t.typeos, os.nomos

SELECT COALESCE(t.typeos, 'TOUS TYPES D''OS'), COALESCE(os.nomos, 'TOUS OS'), COUNT(vm.idvm) AS "nb VMs"
FROM vm
  JOIN os ON vm.idos=os.idos
  JOIN typeos t ON os.idtypeos=t.idtypeos
GROUP BY ROLLUP(t.typeos, os.nomos)
ORDER BY t.typeos, os.nomos


-- ou CASE

-- Q2
Insert into DEPARTEMENT (IDDEPARTEMENT, NOMDEPARTEMENT, NOMUFR) values (7, 'TC', 'IUT Annecy');
Insert into DEPARTEMENT (IDDEPARTEMENT, NOMDEPARTEMENT, NOMUFR) values (8, 'GEA', 'IUT Annecy');

SELECT COALESCE(d.nomufr, 'TOUTES UFR'), COALESCE(d.nomdepartement, 'TOUS DEPARTEMENTS'), COUNT(vm.idvm) AS "nb VMs"
FROM vm
	RIGHT JOIN departement d on vm.iddepartement=d.iddepartement
GROUP BY ROLLUP(d.nomufr, d.nomdepartement)
ORDER BY nomufr, nomdepartement;

-- Q3
CREATE TEMPORARY TABLE SyntheseInstallations (
	idvm 					NUMERIC(4),
	nomvm 					VARCHAR(50),
	numversion 				NUMERIC(2),
	nbinstallationsversion 	NUMERIC(10),
	nbinstallationsvm 		NUMERIC(10)
);

INSERT INTO SyntheseInstallations(idvm, nomvm, numversion, nbinstallationsversion)
SELECT vm.idvm, vm.nomvm, v.numversion, COUNT(*)
FROM installation i
	JOIN versionvm v ON i.idvm=v.idvm AND i.numversion=v.numversion
	JOIN vm ON v.idvm=vm.idvm
GROUP BY vm.idvm, vm.nomvm, v.numversion;

SELECT * FROM SyntheseInstallations ORDER BY idvm;


UPDATE SyntheseInstallations SET nbinstallationsvm=(
SELECT COUNT(*) FROM installation WHERE installation.idvm= SyntheseInstallations.idvm
);

SELECT * FROM SyntheseInstallations ORDER BY idvm;

DROP TABLE SyntheseInstallations;

-- Q4
SELECT l.idlogiciel, l.nomlogiciel, COUNT(*) as nbinstallations, RANK() OVER (ORDER BY count(*) DESC) as classement
	FROM installation i
		RIGHT JOIN logiciel l ON i.idlogiciel=l.idlogiciel
	GROUP BY l.idlogiciel, l.nomlogiciel

-- Q5
CREATE TEMPORARY TABLE temp AS
	SELECT l.idlogiciel, l.nomlogiciel, COUNT(*) as nbinstallations, RANK() OVER (ORDER BY count(*) DESC) as classement
	FROM installation i
		RIGHT JOIN logiciel l ON i.idlogiciel=l.idlogiciel
	GROUP BY l.idlogiciel, l.nomlogiciel;

SELECT *
FROM temp
WHERE classement <=5;

DROP TABLE temp;

-- Q6
With t as (
	SELECT l.idlogiciel, l.nomlogiciel, COUNT(*) as nbinstallations, RANK() OVER (ORDER BY count(*) DESC) as classement
	FROM installation i
		RIGHT JOIN logiciel l ON i.idlogiciel=l.idlogiciel
	GROUP BY l.idlogiciel, l.nomlogiciel)
SELECT *
FROM t
WHERE t.classement <=5

-- Q7
SELECT l.idlogiciel, l.nomlogiciel
FROM logiciel l
	JOIN compatibilite C On l.idlogiciel=c.idlogiciel
	JOIN OS ON c.idos=os.idos
GROUP BY l.idlogiciel, os.idtypeos
HAVING COUNT(DISTINCT os.idtypeos)=1
EXCEPT
SELECT l.idlogiciel, l.nomlogiciel
FROM logiciel l
	JOIN compatibilite C On l.idlogiciel=c.idlogiciel
	JOIN OS ON c.idos=os.idos
	JOIN typeos tos ON os.idtypeos=tos.idtypeos
WHERE tos.typeos<>'Mac OS/X'
EXCEPT
SELECT l.idlogiciel, l.nomlogiciel
FROM logiciel l
	JOIN installation i ON l.idlogiciel=i.idlogiciel

-- Logiciel A
create sequence seq_logiciel start with 60;
Insert into LOGICIEL (IDLOGICIEL, NOMLOGICIEL) values (nextval('seq_logiciel'), 'A');
insert into compatibilite (idlogiciel, idos)
	select currval('seq_logiciel'), idos
	from os
		join typeos on os.idtypeos=typeos.idtypeos
	and typeos='Mac OS/X';

-- Logiciel B
Insert into LOGICIEL (IDLOGICIEL, NOMLOGICIEL) values (nextval('seq_logiciel'), 'B');
insert into compatibilite (idlogiciel, idos)
	select currval('seq_logiciel'), idos
	from os
		join typeos on os.idtypeos=typeos.idtypeos
	and typeos='Mac OS/X';
create sequence seq_installation start with 100;
insert into installation (idinstallation, idvm, numversion, idlogiciel)
	select nextval('seq_installation'), vvm.idvm, vvm.numversion, currval('seq_logiciel')
	from installation i,
		versionvm vvm
	WHERE vvm.dateversion=(select max(dateversion) from versionvm)
	group by vvm.idvm, vvm.numversion

-- Logiciel C
Insert into LOGICIEL (IDLOGICIEL, NOMLOGICIEL) values (nextval('seq_logiciel'), 'C');
insert into compatibilite (idlogiciel, idos)
	select currval('seq_logiciel'), idos
	from os
		join typeos on os.idtypeos=typeos.idtypeos
	and typeos='Mac OS/X';
insert into compatibilite (idlogiciel, idos)
	select currval('seq_logiciel'), idos
	from os
		join typeos on os.idtypeos=typeos.idtypeos
	and typeos='Microsoft Windows';




