CREATE SCHEMA tovar;
SET SEARCH_PATH = 'tovar';

CREATE DOMAIN COST_D AS NUMERIC(8,2)
CHECK (VALUE>0);

CREATE DOMAIN OPERATION_D AS CHAR(1)
CHECK(VALUE IN ('I','D','U','i','d','u'));

CREATE TABLE HISTORY_TOVAR (
    ID_HISTORY INTEGER NOT NULL,
    ID_TOVAR INTEGER NOT NULL,
    DATE_CHANGE DATE NOT NULL,
    OPERATION OPERATION_D NOT NULL,
    NEW_COST COST_D NOT NULL,
    OPERATOR VARCHAR(120));

CREATE TABLE REPORT_TOVAR (
    YEAR_REPORT INTEGER NOT NULL,
    KVARTAL_REPORT INTEGER NOT NULL,
    ID_TOVAR INTEGER NOT NULL,
    VAL INTEGER);

CREATE TABLE SCLAD (
    ID_SCLAD INTEGER NOT NULL,
    ID_TOVAR INTEGER NOT NULL,
    VAL INTEGER NOT NULL CHECK(VAL>0),
    DAT DATE NOT NULL);

CREATE TABLE TOVAR (
    ID_TOVAR INTEGER NOT NULL,
    NAME_TOVAR VARCHAR(20),
    COL_SCLAD INTEGER DEFAULT 0 NOT NULL,
    COST COST_D);

CREATE VIEW HISTORY_CU(
    ID_HISTORY,
    ID_TOVAR,
    DATE_CHANGE,
    OPERATION,
    NEW_COST)
AS
select ID_HISTORY,  ID_TOVAR, DATE_CHANGE, OPERATION, NEW_COST from HISTORY_TOVAR
where HISTORY_TOVAR.operator=USER;


CREATE VIEW TOVAR_12(
    ID_TOVAR,
    NAME_TOVAR,
    COST)
AS
select ID_TOVAR,  NAME_TOVAR, COST from TOVAR
where ID_TOVAR IN (1,2);
--     with check ;


INSERT INTO HISTORY_TOVAR (ID_HISTORY, ID_TOVAR, DATE_CHANGE, OPERATION, NEW_COST, OPERATOR) VALUES (1, 1, '04/23/2001', 'I', 1.56, 'USER');
INSERT INTO HISTORY_TOVAR (ID_HISTORY, ID_TOVAR, DATE_CHANGE, OPERATION, NEW_COST, OPERATOR) VALUES (2, 2, '04/23/2001', 'I', 58.6, 'USER');
INSERT INTO HISTORY_TOVAR (ID_HISTORY, ID_TOVAR, DATE_CHANGE, OPERATION, NEW_COST, OPERATOR) VALUES (3, 3, '04/23/2001', 'I', 5.6, 'USER');
INSERT INTO HISTORY_TOVAR (ID_HISTORY, ID_TOVAR, DATE_CHANGE, OPERATION, NEW_COST, OPERATOR) VALUES (4, 2, '04/23/2001', 'U', 5.83, 'USER');

INSERT INTO REPORT_TOVAR (YEAR_REPORT, KVARTAL_REPORT, ID_TOVAR, VAL) VALUES (2001, 2, 1, 1);
INSERT INTO REPORT_TOVAR (YEAR_REPORT, KVARTAL_REPORT, ID_TOVAR, VAL) VALUES (2000, 4, 2, 3);

INSERT INTO SCLAD (ID_SCLAD, ID_TOVAR, VAL, DAT) VALUES (1, 1, 2, '04/18/2001');
INSERT INTO SCLAD (ID_SCLAD, ID_TOVAR, VAL, DAT) VALUES (2, 1, 3, '04/20/2001');
-- INSERT INTO SCLAD (ID_SCLAD, ID_TOVAR, VAL, DAT) VALUES (3, 1, -4, '04/21/2001');
INSERT INTO SCLAD (ID_SCLAD, ID_TOVAR, VAL, DAT) VALUES (5, 2, 3, '10/15/2000');

INSERT INTO TOVAR (ID_TOVAR, NAME_TOVAR, COL_SCLAD, COST) VALUES (1, 'Шарики', 1, 1.56);
INSERT INTO TOVAR (ID_TOVAR, NAME_TOVAR, COL_SCLAD, COST) VALUES (2, 'Ролики', 3, 5.83);
INSERT INTO TOVAR (ID_TOVAR, NAME_TOVAR, COL_SCLAD, COST) VALUES (3, 'Винтики', 0, 5.6);

ALTER TABLE REPORT_TOVAR ADD CHECK (KVARTAL_REPORT IN (1,2,3,4));
ALTER TABLE HISTORY_TOVAR ADD CONSTRAINT PK_HISTORY_TOVAR PRIMARY KEY (ID_HISTORY);
ALTER TABLE REPORT_TOVAR ADD CONSTRAINT PK_REPORT_TOVAR PRIMARY KEY (YEAR_REPORT, KVARTAL_REPORT, ID_TOVAR);
ALTER TABLE SCLAD ADD CONSTRAINT PK_SCLAD PRIMARY KEY (ID_SCLAD);
ALTER TABLE TOVAR ADD CONSTRAINT PK_TOVAR PRIMARY KEY (ID_TOVAR);
ALTER TABLE HISTORY_TOVAR ADD  CONSTRAINT FK_HISTORY_TOVAR FOREIGN KEY (ID_TOVAR) REFERENCES TOVAR (ID_TOVAR);
ALTER TABLE REPORT_TOVAR ADD  CONSTRAINT FK_REPORT_TOVAR FOREIGN KEY (ID_TOVAR) REFERENCES TOVAR (ID_TOVAR) ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE SCLAD ADD  CONSTRAINT FK_SCLAD FOREIGN KEY (ID_TOVAR) REFERENCES TOVAR (ID_TOVAR) ON DELETE CASCADE ON UPDATE CASCADE;
