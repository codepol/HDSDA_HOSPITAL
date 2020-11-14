DROP DATABASE IF EXISTS HOSPITAL;

CREATE DATABASE HOSPITAL;

USE HOSPITAL;

/*Table structure for table STAFF */

DROP TABLE IF EXISTS STAFF;

CREATE TABLE STAFF (
  StaffNo smallint NOT NULL,
  FName varchar(25) NOT NULL,
  LName varchar(25) NOT NULL,
  DateBorn date NOT NULL,
  Position varchar(25) NOT NULL,
  PRIMARY KEY (StaffNo)
);

/*Table structure for table ISSUES */

DROP TABLE IF EXISTS ISSUES;

CREATE TABLE ISSUES (
  IssueID smallint NOT NULL,
  PatientID smallint NOT NULL,
  IssueDetails text NOT NULL,
  IssueStatus smallint NOT NULL,
  PRIMARY KEY (IssueID)
);

/*Table structure for table ISSUE_STATUSES */

DROP TABLE IF EXISTS ISSUE_STATUSES;

CREATE TABLE ISSUE_STATUSES (
  IssueStatus smallint NOT NULL,
  Description varchar(30) NOT NULL,
  PRIMARY KEY (IssueStatus)
);

/*Table structure for table TREATMENTS */

DROP TABLE IF EXISTS TREATMENTS;

CREATE TABLE TREATMENTS (
  TreatmentID smallint NOT NULL,
  PatientID smallint NOT NULL,
  TreatmentDetails text NOT NULL,
  TreatmentStatus smallint NOT NULL,
  StaffID smallint NOT NULL,
  PRIMARY KEY (TreatmentID)
);

/*Table structure for table TREATMENT_STATUSES */

DROP TABLE IF EXISTS TREATMENT_STATUSES;


CREATE TABLE TREATMENT_STATUSES (
  TreatmentStatus smallint NOT NULL,
  Description varchar(30) NOT NULL,
  PRIMARY KEY (TreatmentStatus)
);


/*Table structure for table PATIENTS */

DROP TABLE IF EXISTS PATIENTS;

CREATE TABLE PATIENTS (
  PatientID smallint NOT NULL,
  FName varchar(25) NOT NULL,
  LName varchar(25) NOT NULL,
  DateBorn date NOT NULL,
  AddrLn1 varchar(25) NOT NULL,
  AddrLn2 varchar(25) NOT NULL,
  AddrLn3 varchar(25) NOT NULL,
  AddrLn4 varchar(25) NULL,
  Mobile int NOT NULL,
  PRIMARY KEY (PatientID)
);


/*Foreign keys for the tables */

ALTER TABLE TREATMENTS ADD CONSTRAINT treatment_fk_1 FOREIGN KEY (PatientID) REFERENCES PATIENTS (PatientID);
ALTER TABLE TREATMENTS ADD CONSTRAINT treatment_fk_2 FOREIGN KEY (StaffID) REFERENCES STAFF (StaffNo);
ALTER TABLE TREATMENTS ADD CONSTRAINT treatment_fk_3 FOREIGN KEY (TreatmentStatus) REFERENCES TREATMENT_STATUSES (TreatmentStatus);
ALTER TABLE ISSUES ADD CONSTRAINT issue_fk_1 FOREIGN KEY (PatientID) REFERENCES PATIENTS (PatientID);
ALTER TABLE ISSUES ADD CONSTRAINT issue_fk_2 FOREIGN KEY (IssueStatus) REFERENCES ISSUE_STATUSES (IssueStatus);


/*Data for the table ISSUE_STATUSES */

LOCK TABLES ISSUE_STATUSES WRITE;

insert into ISSUE_STATUSES (IssueStatus,Description) values (1,'Ongoing'),(2,'Recovery and Release'),(3,'Deceased'),(4,'Recovery and Kept In');

UNLOCK TABLES;

/*Data for the table TREATMENT_STATUSES */

LOCK TABLES TREATMENT_STATUSES WRITE;

insert into TREATMENT_STATUSES (TreatmentStatus,Description) values (1,'In Progress'),(2,'Rejected'),(3,'Finished');

UNLOCK TABLES;

-- Imported data to PATIENTS, ISSUES, STAFF and TREATMENTS via CSV import

## Stored Procedure to return patient, treatment and issue details when passing a variable of PatientID

DROP PROCEDURE IF EXISTS get_patient_details;

DELIMITER $$
CREATE procedure get_patient_details (IN QueryPatientID varchar(100))
BEGIN
select PATIENTS.*, ISSUES.IssueDetails, TREATMENTS.TreatmentDetails, concat(STAFF.FName, " ", STAFF.LName) AS StaffFullName
from PATIENTS
left join ISSUES on PATIENTS.PatientID = ISSUES.PatientID
left join TREATMENTS on PATIENTS.PatientID = TREATMENTS.PatientID
left join STAFF on TREATMENTS.StaffID = STAFF.StaffNo
where PATIENTS.PatientID = QueryPatientID;
END $$
DELIMITER ;

/*test to check it's working OK

call get_patient_details (2);

check OK*/

## Trigger to update treatment status once patient has been updated to "discharged"

DROP TRIGGER IF EXISTS recovery_update_patient;
DELIMITER $$
CREATE TRIGGER recovery_update_patient 
	AFTER UPDATE ON ISSUES
    FOR EACH ROW BEGIN
    UPDATE TREATMENTS
    SET TreatmentStatus = 3 ## set to finished
	WHERE TREATMENTS.PatientID = new.PatientID and new.IssueStatus = 2; #where issue has been changed to Recovery and Release
END$$
DELIMITER ;

/*test to check it's working OK

update ISSUES SET IssueStatus = 2 where PatientID = 1;

check OK*/