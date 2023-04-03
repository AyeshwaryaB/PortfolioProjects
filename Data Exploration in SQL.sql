/* 

Covid 19 Data Exploration

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

-- 	Queries to check the data

SELECT * FROM portfolioproject.coviddeaths;

SELECT * FROM portfolioproject.covidvaccinations;

SELECT
location,
date,
total_cases,
new_cases,
total_deaths,
population
FROM portfolioproject.coviddeaths
ORDER BY 1,2;

---------------------------------------------------------------------------------------

-- Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

SELECT
location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases) * 100 as DeathPercentage
FROM portfolioproject.coviddeaths
WHERE location LIKE '%states%';

---------------------------------------------------------------------------------------

-- Total Cases vs Population
-- Shows what percentage of population infected with covid

SELECT
location,
date,
population,
total_cases,
(total_cases/population) * 100 as PercentPopulationInfected
FROM portfolioproject.coviddeaths;
-- where location like '%states%' 

---------------------------------------------------------------------------------------

-- Countries with Highest Infection Rate compared to Population

SELECT
location,
population,
MAX(total_cases),
MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1,2
ORDER BY PercentPopulationInfected DESC; 

---------------------------------------------------------------------------------------

-- Countries with Highest Death Count per Population

SELECT 
location, 
MAX(CAST(total_deaths AS UNSIGNED)) as TotalDeathCount
FROM portfolioProject.covidDeaths
WHERE continent is not null 
GROUP BY 1
ORDER BY TotalDeathCount DESC;

---------------------------------------------------------------------------------------

-- Continent with Highest Death Count per Population

SELECT
continent,
MAX(CAST(total_deaths AS UNSIGNED)) as TotalDeathCount
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1
ORDER BY TotalDeathCount DESC;

---------------------------------------------------------------------------------------

-- GLOBAL NUMBERS

SELECT
date,
SUM(new_cases) as total_cases,
SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 as deathpercentage
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY 1;

SELECT
SUM(new_cases) as total_cases,
SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 as deathpercentage
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL;

---------------------------------------------------------------------------------------

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
-- Date included.Calculated cummulative sum or rolling value using Window function SUM to get RollingPeopleVaccinated.Calculated the percentage of vaccinations for location.

WITH PopvsVac AS
(
select 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(v.new_vaccinations)over(partition by location order by d.location,d.date )as RollingPeopleVaccinated
FROM portfolioproject.coviddeaths d
JOIN portfolioproject.covidvaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) * 100 as PercentPopulationVaccinated
FROM PopvsVac;

-- OR 
-- Can be done this way too
-- Date excluded.Directly summed up the vaccinations without using window function and calculated the percentage of vaccinations for location.

SELECT 
d.continent,
d.location,
d.population,
SUM(v.new_vaccinations),
(SUM(v.new_vaccinations)/Population)* 100  as PercentPopulationVaccinated
FROM portfolioproject.coviddeaths d
JOIN portfolioproject.covidvaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
GROUP BY 1, 2,3
ORDER BY 1,2;

---------------------------------------------------------------------------------------

-- VIEWS

-- Creating views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT 
d.continent,
d.location,
d.date,
d.population,
v.new_vaccinations,
SUM(v.new_vaccinations)over(partition by location order by d.location,d.date )as RollingPeopleVaccinated
FROM portfolioproject.coviddeaths d
JOIN portfolioproject.covidvaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

---------------------------------------------------------------------------------------

-- GENERAL QUERIES

-- Check distinct values for continent

SELECT DISTINCT continent 
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL;

-- Creating test tables(when in doubt create test tables with 1 or 2 rows to test data)
CREATE TABLE portfolioproject.coviddeaths_spaces as select * from portfolioproject.coviddeaths;

-- Replacing space with NULL
UPDATE portfolioproject.coviddeaths
SET continent = NULL
WHERE continent = '';

-- Converting date in format (4/10/21) to the datetime format after loading the excel in mysql

UPDATE PortfolioProject.coviddeaths_bkp
SET date = STR_TO_DATE(date, '%m/%d/%y %h:%i:%s %p');



