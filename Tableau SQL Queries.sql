/*

Queries used for visualization in Tableau

*/

-- Global Numbers

SELECT
SUM(new_cases) as total_cases,
SUM(new_deaths) as total_deaths,
(SUM(new_deaths)/SUM(new_cases))*100 AS deathpercentage
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL;

---------------------------------------------------------------------------------------

-- Looking at TotalDeathcount per Location

SELECT
location,
SUM(new_deaths) as TotalDeathcount
FROM portfolioproject.coviddeaths
WHERE continent IS NULL and location NOT IN ('World', 'European Union', 'International')
GROUP BY 1
ORDER BY TotalDeathcount DESC;

---------------------------------------------------------------------------------------

-- Looking at Countries with Highest Infection Rate compared to Population (no date)

SELECT
location,
population,
MAX(total_cases)as HighestInfectedCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.coviddeaths
GROUP BY 1,2
ORDER BY PercentPopulationInfected DESC;

---------------------------------------------------------------------------------------

-- Looking at Countries with Highest Infection Rate compared to Population (date included)

SELECT
location,
population,
date,
MAX(total_cases) as HighestInfectedCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject.coviddeaths
GROUP BY 1,2,3
ORDER BY PercentPopulationInfected DESC
