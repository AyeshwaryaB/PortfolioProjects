/* Healthcare Data  Analysis - Data exploration & Data cleaning */

SELECT * FROM healthcare.sample_data;
------------------------------------
-- Updating date formats

UPDATE Healthcare.sample_data 
SET DOB = STR_TO_DATE(REPLACE(DOB, '/', '-'), '%m-%d-%Y')
WHERE DOB IS NOT NULL;

UPDATE Healthcare.sample_data 
SET AdmissionDate = STR_TO_DATE(REPLACE(AdmissionDate, '/', '-'), '%m-%d-%Y')
WHERE AdmissionDate IS NOT NULL;

UPDATE Healthcare.sample_data 
SET DischargeDate = STR_TO_DATE(REPLACE(DischargeDate, '/', '-'), '%m-%d-%Y')
WHERE DischargeDate IS NOT NULL;
------------------------------------
-- Updating names of Cities

SELECT city, COUNT(*) FROM healthcare.patient_data
GROUP By city;

UPDATE healthcare.patient_data
SET city = 'Arverne'
WHERE city = 'Averne';
------------------------------------
-- Splitting column PrimaryDiagnosisName into DiagnosisName, DiagnosisType

SELECT
PrimaryDiagnosisName,
SUBSTRING_INDEX(PrimaryDiagnosisName,',',1) AS Diagnosis,
CASE 
WHEN PrimaryDiagnosisName LIKE '%,%' THEN SUBSTRING_INDEX(TRIM(PrimaryDiagnosisName), ',', -1) 
ELSE NULL
END AS Type
FROM healthcare.sample_data;

ALTER TABLE healthcare.patient_data
ADD DiagnosisName text;

ALTER TABLE healthcare.patient_data
ADD DiagnosisType text;

UPDATE healthcare.patient_data
SET DiagnosisName = substring_index(PrimaryDiagnosisName,',',1);

UPDATE healthcare.patient_data
SET DiagnosisType = CASE 
WHEN PrimaryDiagnosisName LIKE '%,%' THEN SUBSTRING_INDEX(TRIM(PrimaryDiagnosisName), ',', -1) 
ELSE NULL
END;
------------------------------------
-- Creating a backup table

CREATE TABLE healthcare.patient_data AS SELECT * FROM healthcare.sample_data;

SELECT COUNT(*) FROM healthcare.patient_data;

SELECT * FROM healthcare.patient_data;

------------------------------------
-- Deleting columns that are not needed

ALTER TABLE healthcare.patient_data
DROP COLUMN PatientName,
DROP COLUMN FirstName,
DROP COLUMN LastName,
DROP COLUMN State,
DROP COLUMN Address,
DROP COLUMN ZipCode,
DROP COLUMN ChartNum,
DROP COLUMN PrimaryTherapist,
DROP COLUMN PrimaryInsuranceCode,
DROP COLUMN PrimaryDiagnosisCode,
DROP COLUMN PrimaryDiagnosisCodeAndName,
DROP COLUMN ProgressNote,
DROP COLUMN DateOfService,
DROP COLUMN PrimaryDiagnosisName;
------------------------------------
-- Calculating Age & AgeGroups.
-- Adding & updating 2 new columns Age & AgeGroups to the table

SELECT medicalrecordnumber,dob,
TIMESTAMPDIFF(YEAR,DOB, MIN(Admissiondate)) AS Age,
CASE
WHEN TIMESTAMPDIFF(YEAR, DOB, MIN(Admissiondate)) < '12' THEN 'Invalid'
WHEN TIMESTAMPDIFF(YEAR, DOB, MIN(Admissiondate)) BETWEEN '12' AND '18' THEN 'Adolescent'
WHEN TIMESTAMPDIFF(YEAR, DOB, MIN(Admissiondate)) BETWEEN '19' AND '30' THEN 'Young Adults'
WHEN TIMESTAMPDIFF(YEAR, DOB, MIN(Admissiondate)) BETWEEN '31' AND '60' THEN 'Middle Age Adults'
ELSE 'Senior Citizens'
END AS Age_groups
FROM healthcare.patient_data
GROUP BY medicalrecordnumber,DOB;

ALTER TABLE healthcare.patient_data
ADD Age TEXT;

ALTER TABLE healthcare.patient_data
ADD AgeGroup TEXT;

UPDATE healthcare.patient_data AS pd
JOIN (
  SELECT
    medicalrecordnumber,
    dob, 
    TIMESTAMPDIFF(YEAR, DOB, MIN(Admissiondate)) AS Age
  FROM healthcare.patient_data
  GROUP BY medicalrecordnumber,DOB
) AS a ON pd.DOB = a.DOB AND pd.medicalrecordnumber = a.medicalrecordnumber
SET pd.age = a.age;

UPDATE healthcare.patient_data 
SET AgeGroup = CASE
WHEN age < '12' THEN 'Invalid'
WHEN age BETWEEN '12' AND '18' THEN 'Adolescent'
WHEN age BETWEEN '19' AND '30' THEN 'Young Adults'
WHEN age BETWEEN '31' AND '60' THEN 'Middle Age Adults'
ELSE 'Senior Citizens'
END;
------------------------------------
-- Looking at PercentageOfPatients per City

SELECT COUNT(medicalrecordnumber) FROM healthcare.patient_data;

SELECT city, COUNT(DISTINCT medicalrecordnumber)FROM healthcare.patient_data
GROUP BY 1 ;

SELECT city,medicalrecordnumber, COUNT(*) FROM healthcare.patient_data
GROUP BY 1 ,2;

-- The query below is incorrect because using the SUM function inside the COUNT function is not allowed.To fix this error, 
-- calculate the total count of patients across all cities, and then use that value to calculate the percentage for each city

SELECT 
CITY,
COUNT(DISTINCT medicalrecordnumber),
(COUNT(DISTINCT medicalrecordnumber)/(SUM(COUNT(DISTINCT medicalrecordnumber)))* 100 AS Percentage
FROM healthcare.patient_data
GROUP BY 1 ;

-- Here are 2 ways of calculating the PercentageOfPatients per City

SELECT CITY, 
COUNT(DISTINCT medicalrecordnumber) AS PatientCount,
ROUND(COUNT(DISTINCT medicalrecordnumber) / SUM(COUNT(DISTINCT medicalrecordnumber)) OVER()* 100, 2) AS Percentage
FROM healthcare.patient_data
GROUP BY CITY;

SELECT 
    CITY,
    COUNT(DISTINCT medicalrecordnumber),
    ROUND((COUNT(DISTINCT medicalrecordnumber) / 
    (SELECT COUNT(DISTINCT medicalrecordnumber) FROM healthcare.patient_data)) * 100, 2) AS Percentage
FROM healthcare.patient_data
GROUP BY CITY;
------------------------------------

-- Looking at the most Profitable Program

SELECT ROUND(SUM(charge),2) FROM healthcare.patient_data;

SELECT program,
ROUND(SUM(charge),2)
FROM healthcare.patient_data
GROUP BY program; 

SELECT Program,
ROUND(SUM(charge)/SUM(SUM(charge)) OVER()* 100,2) AS HighestProfitpercentage
FROM healthcare.patient_data
GROUP BY program;

------------------------------------
-- Looking at the Number of Admissions per Year

SELECT COUNT(DISTINCT(admissiondate)) FROM healthcare.patient_data;

SELECT 
medicalrecordnumber,
COUNT(DISTINCT(admissiondate))
FROM healthcare.patient_data
GROUP BY medicalrecordnumber;

SELECT 
medicalrecordnumber,
year(admissiondate) as Year,
COUNT(distinct(admissiondate)) AS NumOfAdmissions
FROM healthcare.patient_data
WHERE medicalrecordnumber = '7902'
GROUP BY medicalrecordnumber,year;

-- 11994 - 2, 9739 - 4 , 7902 - 4

SELECT 
year(admissiondate) as Year,
COUNT(distinct(admissiondate)) AS NumOfAdmissions
FROM healthcare.patient_data
GROUP BY year;

------------------------------------



