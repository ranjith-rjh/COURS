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
   IDLOGICIEL           NUMERIC(5)            not null,
   IDOS                 NUMERIC(3)            not null,
   constraint PK_COMPATIBILITE primary key (IDLOGICIEL, IDOS)
);

/*==============================================================*/
/* Table : DEMANDEUR                                            */
/*==============================================================*/
create table DEMANDEUR 
(
   IDDEMANDEUR          NUMERIC(5)          not null,
   NOMDEMANDEUR         VARCHAR(50)         not null,
   PRENOMDEMANDEUR      VARCHAR(50)         not null,
   EMAIL                VARCHAR(80)         not null,
   TYPEDEMANDEUR        VARCHAR(20)         not null 
   		constraint CK_DEMANDEUR_TYPE check(TYPEDEMANDEUR in ('Permanent', 'Vacataire')),

   RUE                  VARCHAR(200),
   CP                   CHAR(5),
   VILLE                VARCHAR(50),
   TELFIXE              CHAR(10),
   ENTREPRISE		VARCHAR(50),
   NUMBUREAU		CHAR(4),

   constraint PK_DEMANDEUR primary key (IDDEMANDEUR)
);

/*==============================================================*/
/* Table : DEPARTEMENT                                          */
/*==============================================================*/
create table DEPARTEMENT 
(
   IDDEPARTEMENT         NUMERIC(2)          not null,
   NOMDEPARTEMENT        VARCHAR(20)         not null,
   NOMUFR			  VARCHAR(20)	    not null,

   constraint PK_DEPARTEMENT primary key (IDDEPARTEMENT)
);

/*==============================================================*/
/* Table : INSTALLATION                                         */
/*==============================================================*/
create table INSTALLATION 
(
   IDINSTALLATION       NUMERIC(6)            not null,
   IDVM                 NUMERIC(4)            not null,
   NUMVERSION           NUMERIC(2)            not null,
   IDLOGICIEL           NUMERIC(5)            not null,

   constraint PK_INSTALLATION primary key (IDINSTALLATION),
   constraint UQ_INSTALLATION unique (IDVM, NUMVERSION, IDLOGICIEL)
);

/*==============================================================*/
/* Table : LOGICIEL                                             */
/*==============================================================*/
create table LOGICIEL 
(
   IDLOGICIEL           NUMERIC(5)          not null,
   NOMLOGICIEL          VARCHAR(50)         not null,

   constraint PK_LOGICIEL primary key (IDLOGICIEL)
);

/*==============================================================*/
/* Table : OS                                                   */
/*==============================================================*/
create table OS 
(
   IDOS                 NUMERIC(3)          not null,
   IDTYPEOS             NUMERIC(2)          not null,
   NOMOS                VARCHAR(30)         not null,

   constraint PK_OS primary key (IDOS)
);

/*==============================================================*/
/* Table : PLATEFORME                                          */
/*==============================================================*/
create table PLATEFORME 
(
   IDPLATEFORME         NUMERIC(2)          not null,
   NOMPLATEFORME        VARCHAR(30)         not null,

   constraint PK_PLATEFORME primary key (IDPLATEFORME)
);

/*==============================================================*/
/* Table : TYPEOS                                               */
/*==============================================================*/
create table TYPEOS 
(
   IDTYPEOS             NUMERIC(2)          not null,
   TYPEOS               VARCHAR(30)         not null,

   constraint PK_TYPEOS primary key (IDTYPEOS)
);

/*==============================================================*/
/* Table : VERSIONVM                                            */
/*==============================================================*/
create table VERSIONVM 
(
   IDVM                 NUMERIC(4)             not null,
   NUMVERSION           NUMERIC(2)             not null,
   DATEVERSION          DATE            default current_date not null,
   
   constraint PK_VERSIONVM primary key (IDVM, NUMVERSION)
);

/*==============================================================*/
/* Table : VM                                                   */
/*==============================================================*/
create table VM 
(
   IDVM                 NUMERIC(4)            not null,
   IDPLATEFORME         NUMERIC(2)            not null,
   IDDEMANDEUR          NUMERIC(5)            not null,
   IDDEPARTEMENT        NUMERIC(2)            not null,
   IDOS                 NUMERIC(3)            not null,
   NOMVM                VARCHAR(50)           not null,
   DESCRIPTION          VARCHAR(500)          not null,
   TAILLEDD             NUMERIC(6,2)          not null,
   MEMOIRERAM           NUMERIC(5)            not null
   		constraint CK_VM_MEMOIRERAM check(MEMOIRERAM <= 16384),

   TYPESTOCKAGE         VARCHAR(30)         not null
   		constraint CK_VM_TYPESTOCKAGE check(TYPESTOCKAGE in ('Dynamiquement alloué', 'Taille fixe')),

   constraint PK_VM primary key (IDVM)
);


alter table COMPATIBILITE
   add constraint FK_COMPATIBILITE_IDLOGICIEL foreign key (IDLOGICIEL)
      references LOGICIEL (IDLOGICIEL) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table COMPATIBILITE
   add constraint FK_COMPATIBILITE_IDOS foreign key (IDOS)
      references OS (IDOS) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table INSTALLATION
   add constraint FK_INSTALLATION_VERSIONVM foreign key (IDVM, NUMVERSION)
      references VERSIONVM (IDVM, NUMVERSION) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table INSTALLATION
   add constraint FK_INSTALLATION_LOGICIEL foreign key (IDLOGICIEL)
      references LOGICIEL (IDLOGICIEL) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table OS
   add constraint FK_OS_TYPEOS foreign key (IDTYPEOS)
      references TYPEOS (IDTYPEOS) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table VERSIONVM
   add constraint FK_VERSIONVM_VM foreign key (IDVM)
      references VM (IDVM) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table VM
   add constraint FK_VM_OS foreign key (IDOS)
      references OS (IDOS) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table VM
   add constraint FK_VM_PLATEFORME foreign key (IDPLATEFORME)
      references PLATEFORME (IDPLATEFORME) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table VM
   add constraint FK_VM_DEMANDEUR foreign key (IDDEMANDEUR)
      references DEMANDEUR (IDDEMANDEUR) ON UPDATE RESTRICT ON DELETE RESTRICT;

alter table VM
   add constraint FK_VM_DEPARTEMENT foreign key (IDDEPARTEMENT)
      references DEPARTEMENT (IDDEPARTEMENT) ON UPDATE RESTRICT ON DELETE RESTRICT;
