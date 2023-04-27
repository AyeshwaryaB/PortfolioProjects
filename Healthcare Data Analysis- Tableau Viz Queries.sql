/* Healthcare Data Analysis: Tableau Viz Queries */

-- Looking at PercentageOfPatients per City

SELECT CITY, 
COUNT(DISTINCT medicalrecordnumber) AS PatientCount,
ROUND(COUNT(DISTINCT medicalrecordnumber) / SUM(COUNT(DISTINCT medicalrecordnumber)) OVER()* 100, 2) AS PercentageOfPatients
FROM healthcare.patient_data
GROUP BY CITY;
------------------------------------

-- Looking at Age groups that has highest percentage of admission rate

SELECT 
Agegroup,
ROUND((COUNT(agegroup)/SUM(COUNT(*)) OVER()) * 100,2) as PercentageOfAdmission
FROM healthcare.patient_data  
GROUP BY Agegroup;
------------------------------------

-- Looking at the most Profitable Program

SELECT Program,
ROUND(SUM(charge)/SUM(SUM(charge)) OVER()* 100,2) AS HighestProfitpercentage
FROM healthcare.patient_data
GROUP BY program;
------------------------------------

-- Looking at the Number of Admissions per Year

SELECT 
year(admissiondate) as Year,
COUNT(distinct(admissiondate)) AS NumOfAdmissions
FROM healthcare.patient_data
GROUP BY year;
