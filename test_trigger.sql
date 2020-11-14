USE HOSPITAL;

 ## test to check it's working OK

update ISSUES SET IssueStatus = 2 where PatientID = 1;

select * from TREATMENTS;