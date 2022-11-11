/*==============================================================*/
/* Nom de SGBD :  PostgreSQL                                    */
/*==============================================================*/

drop table if exists COMPATIBILITE cascade;
drop table if exists DEMANDEUR cascade;
drop table if exists DEPARTEMENT cascade;
drop table if exists INSTALLATION cascade;
drop table if exists LOGICIEL cascade;
drop table if exists OS cascade;
drop table if exists PLATEFORME cascade;
drop table if exists TYPEOS cascade;
drop table if exists VERSIONVM cascade;
drop table if exists VM cascade;

/*==============================================================*/
/* Table : COMPATIBILITE                                        */
/*==============================================================*/
create table COMPATIBILITE 
(
   IDLOGICIEL           NUMERIC(5)            not null, -- Clé primaire et Clé étrangère qui référence la table Logiciel
   IDOS                 NUMERIC(3)            not null -- Clé primaire et Clé étrangère qui référence la table OS

   CONSTRAINT pk_compatibilite PRIMARY KEY (IDLOGICIEL, IDOS)
   CONSTRAINT fk_compatibilite_idlogiciel FOREIGN KEY REFERENCES LOGICIEL(IDLOGICIEL)
   CONSTRAINT fk_compatibilite_idos FOREIGN KEY REFERENCES OS(IDOS)
);

/*==============================================================*/
/* Table : DEMANDEUR                                            */
/*==============================================================*/
create table DEMANDEUR 
(
   IDDEMANDEUR          NUMERIC(5)          not null, -- Clé primaire
   NOMDEMANDEUR         VARCHAR(50)         not null,
   PRENOMDEMANDEUR      VARCHAR(50)         not null,
   EMAIL                VARCHAR(80)         not null,
   TYPEDEMANDEUR        VARCHAR(20)         not null, -- Contrainte de validation. Valeurs possibles : Permanent, Vacataire
   RUE                  VARCHAR(200),
   CP                   CHAR(5),
   VILLE                VARCHAR(50),
   TELFIXE              CHAR(10),
   ENTREPRISE			VARCHAR(50),
   NUMBUREAU			CHAR(4)

   CONSTRAINT pk_demandeur PRIMARY KEY(IDDEMANDEUR)
   CONSTRAINT ck_demandeur_type_demandeur CHECK TYPEDEMANDEUR IN ("Permanent", "Vacataire")
);

/*==============================================================*/
/* Table : DEPARTEMENT                                          */
/*==============================================================*/
create table DEPARTEMENT 
(
   IDDEPARTEMENT         NUMERIC(2)          not null, -- Clé primaire 
   NOMDEPARTEMENT        VARCHAR(20)         not null,
   NOMUFR				 VARCHAR(20)		 not null

   CONSTRAINT pk_departement PRIMARY KEY(IDDEPARTEMENT)

);

/*==============================================================*/
/* Table : INSTALLATION                                         */
/*==============================================================*/
create table INSTALLATION 
(
   IDINSTALLATION       NUMERIC(6)            not null, -- Clé primaire 
   IDVM                 NUMERIC(4)            not null, -- Participe à la clé étrangère qui référence la table VersionVM, Participe à la clé unique
   NUMVERSION           NUMERIC(2)            not null, -- Participe à la clé étrangère qui référence la table VersionVM, Participe à la clé unique
   IDLOGICIEL           NUMERIC(5)            not null -- Participe à la clé étrangère qui référence la table Logiciel, Participe à la clé unique

   CONSTRAINT pk_installation PRIMARY KEY(IDINSTALLATION)
   CONSTRAINT fk_installation_idvm FOREIGN KEY REFERENCES VERSIONVM(IDVM)
   CONSTRAINT fk_installation_numversion FOREIGN KEY REFERENCES VERSIONVM(NUMVERSION)
   CONSTRAINT fk_installation_idlogiciel FOREIGN KEY REFERENCES LOGICIEL(IDLOGICIEL)
   CONSTRAINT uq_installation_idvm_numversion_idlogiciel UNIQUE (IDVM, NUMVERSION, IDLOGICIEL)
);

/*==============================================================*/
/* Table : LOGICIEL                                             */
/*==============================================================*/
create table LOGICIEL 
(
   IDLOGICIEL           NUMERIC(5)          not null, -- Clé primaire 
   NOMLOGICIEL          VARCHAR(50)         not null

   CONSTRAINT pk_logiciel PRIMARY KEY (IDLOGICIEL)
);

/*==============================================================*/
/* Table : OS                                                   */
/*==============================================================*/
create table OS 
(
   IDOS                 NUMERIC(3)          not null, -- Clé primaire 
   IDTYPEOS             NUMERIC(2)          not null, -- Clé étrangère qui référence la table TypeOS
   NOMOS                VARCHAR(30)         not null

   CONSTRAINT pk_os PRIMARY KEY (IDOS)
   CONSTRAINT fk_os_idtypeos FOREIGN KEY (IDTYPEOS) REFERENCES TYPEOS(IDTYPEOS)
);

/*==============================================================*/
/* Table : PLATEFORME                                          */
/*==============================================================*/
create table PLATEFORME 
(
   IDPLATEFORME         NUMERIC(2)          not null, -- Clé primaire
   NOMPLATEFORME        VARCHAR(30)         not null

   CONSTRAINT pk_plateforme PRIMARY KEY (IDPLATEFORME)

);

/*==============================================================*/
/* Table : TYPEOS                                               */
/*==============================================================*/
create table TYPEOS 
(
   IDTYPEOS             NUMERIC(2)          not null, -- Clé primaire
   TYPEOS               VARCHAR(30)         not null

   CONSTRAINT pk_typeos PRIMARY KEY (IDTYPEOS)
);

/*==============================================================*/
/* Table : VERSIONVM                                            */
/*==============================================================*/
create table VERSIONVM 
(
   IDVM                 NUMERIC(4)            not null, -- Clé primaire, Clé étrangère qui référence la table VM
   NUMVERSION           NUMERIC(2)            not null, -- Clé primaire
   DATEVERSION          DATE                  not null -- Par défaut date du jour (sysdate)

   CONSTRAINT pk_versionvm PRIMARY KEY (IDVM, NUMVERSION)
   CONSTRAINT fk_versionvm_idvm FOREIGN KEY (IDVM) REFERENCES VM(IDVM)
);

/*==============================================================*/
/* Table : VM                                                   */
/*==============================================================*/
create table VM 
(
   IDVM                 NUMERIC(4)            not null, -- Clé primaire
   IDPLATEFORME         NUMERIC(2)            not null, -- Clé étrangère qui référence la table Plateforme
   IDDEMANDEUR          NUMERIC(5)            not null, -- Clé étrangère qui référence la table Demandeur
   IDDEPARTEMENT        NUMERIC(2)            not null, -- Clé étrangère qui référence la table Département
   IDOS                 NUMERIC(3)            not null, -- Clé étrangère qui référence la table OS
   NOMVM                VARCHAR(50)           not null,
   DESCRIPTION          VARCHAR(500)          not null,
   TAILLEDD             NUMERIC(6,2)          not null,
   MEMOIRERAM           NUMERIC(5)            not null, -- Contrainte de validation. Doit être inférieur à 16384 Mo.
   TYPESTOCKAGE         VARCHAR(30)           not null -- Contrainte de validation. Valeurs possibles : Dynamiquement alloué, Taille fixe.

   CONSTRAINT pk_vm PRIMARY KEY (IDVM)
   CONSTRAINT fk_vm_idplateforme FOREIGN KEY (IDPLATEFORME) REFERENCES PLATEFORME(IDPLATEFORME)
   CONSTRAINT fk_vm_iddemandeur FOREIGN KEY (IDDEMANDEUR) REFERENCES DEMANDEUR (IDDEMANDEUR)
   CONSTRAINT fk_vm_iddepartement FOREIGN KEY (IDDEPARTEMENT) REFERENCES DEPARTEMENT(IDDEPARTEMENT)
   CONSTRAINT fk_vm_os FOREIGN KEY (IDOS) REFERENCES OS(IDOS)

   CONSTRAINT ck_vm_memoireram CHECK (MEMOIRERAM < 16384)
   CONSTRAINT ck_vm_typestockage CHECK TYPESTOCKAGE IN ("Dynamiquement alloue", "Taille fixe")
);
