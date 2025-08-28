/*
Queries for Tableau Visualization
*/

-- 1 --
-- Showing the total number of deaths worldwide and the percentage
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE continent is not null AND continent <> '';


-- 2 --
-- Countries with Highest Total Death Count per Population

SELECT Location, SUM(cast(Total_Deaths AS SIGNED)) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE (continent is null OR continent = '') AND location not in ('World', 'European Union', 'International')
GROUP BY Location
ORDER BY TotalDeathCount desc;


-- 3 --
-- Country with highest infection rate compared to its population
SELECT Location, Population, MAX(Total_Cases) as HighestInfectionCount, ROUND(MAX(total_cases) / population * 100, 2) AS InfectedPopulationPercentage
FROM PortfolioProject.coviddeaths
GROUP BY population, location
ORDER BY InfectedPopulationPercentage desc;


-- 4 --
-- Country with highest infection rate compared to its population with dates
SELECT Location, Population,Date, MAX(Total_Cases) as HighestInfectionCount, ROUND(MAX(Total_Cases/Population)*100, 2) AS InfectedPopulationPercentage
FROM PortfolioProject.coviddeaths
GROUP BY Population, Location, Date
ORDER BY InfectedPopulationPercentage desc;
