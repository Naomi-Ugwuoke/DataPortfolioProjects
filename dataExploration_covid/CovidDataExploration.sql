SELECT * FROM PortfolioProject.coviddeaths
ORDER BY 3,4;

-- SELECT * FROM PortfolioProject.covidvaccinations;

SELECT location, date, total_Cases, new_cases, total_deaths, population
FROM PortfolioProject.coviddeaths
ORDER BY 1, 2;

-- Looking at total cases vs total deaths 
-- Death percentage shows the likelihood of dying if you contract covid in Canada
SELECT Location, Date, Total_Deaths, Total_Cases,  ROUND((Total_Deaths/Total_Cases)*100, 2) AS DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE location LIKE '%Canada%'
ORDER BY 1, 2;

-- Total death count and population
SELECT 
    Location, 
    SUM(Total_Deaths) AS TotalDeathCount,
    SUM(Total_Cases) AS TotalCaseCount,
    ROUND((SUM(Total_Deaths) / SUM(Total_Cases)) * 100, 2) AS DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE Location LIKE '%Canada%'
GROUP BY Location;

-- Looking at the total cases vs the population 
-- Shows what percentage of the population in Canada got Covid
SELECT Location, Date, Total_Cases, Population, ROUND((Total_Cases/Population)*100,2) AS CovidPositivePercentage
FROM PortfolioProject.coviddeaths
WHERE location LIKE '%canada%'
ORDER BY 1, 2;

-- Country with highest infection rate compared to its population
SELECT Location, Population, MAX(Total_Cases) as HighestInfectionCount, ROUND(MAX(Total_Cases/Population)*100, 2) AS InfectedPopulationPercentage
FROM PortfolioProject.coviddeaths
GROUP BY population, location
ORDER BY InfectedPopulationPercentage desc;

-- Country with the highest death count
SELECT Location, MAX(cast(Total_Deaths AS SIGNED)) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent is not null OR continent <> ''
GROUP BY Location
ORDER BY TotalDeathCount desc;

-- Continent with the highest death count
SELECT Continent, MAX(cast(Total_Deaths AS SIGNED)) AS TotalDeathCount
FROM PortfolioProject.coviddeaths
WHERE continent is not null AND continent <> ''
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Global total
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject.coviddeaths
WHERE continent is not null AND continent <> ''
ORDER BY 1, 2;

-- Looking for (rolling) total number of population that has received at least one vaccination
SELECT 
	dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent is not null AND dea.continent <> ''
ORDER BY 2, 3;

-- Using CTE to calculate the Rolling Percentage of vaccinated Population 
WITH PopVsVacc(Continent, Location, Date, Population, new_vaccinations, RollingCountPeopleVaccinated)
AS (SELECT 
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountPeopleVaccinated
	FROM PortfolioProject.coviddeaths dea
	JOIN PortfolioProject.covidvaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND dea.continent <> ''
)
SELECT *, ROUND((RollingCountPeopleVaccinated/Population)*100, 2) AS VaccinatePercentage
FROM PopVsVacc
WHERE Population IS NOT NULL;

-- Using CTE to show a summary view that just shows the latest vaccination percentage per country
WITH PopVsVacc(Continent, Location, Date, Population, new_vaccinations, RollingCountPeopleVaccinated)
AS (SELECT 
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountPeopleVaccinated
	FROM PortfolioProject.coviddeaths dea
	JOIN PortfolioProject.covidvaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND dea.continent <> ''
)
SELECT 
	Continent, Location, MAX(Date) AS LatestDate, MAX(RollingCountPeopleVaccinated) AS TotalVaccinated, MAX(Population) AS PopulationCount, 
	ROUND(MAX(RollingCountPeopleVaccinated) / MAX(Population) * 100, 2) AS VaccinatedPercent
FROM PopVsVacc
WHERE Population IS NOT NULL
GROUP BY Continent, Location
ORDER BY VaccinatedPercent, Continent;

-- ALTERNATIVE Using Temp Tables to show a summary view that just shows the latest vaccination percentage per country
-- creating the temp table
DROP TEMPORARY TABLE IF EXISTS PercentagePopulationVaccinated; 

CREATE TEMPORARY TABLE PercentagePopulationVaccinated AS
WITH PopVsVacc(Continent, Location, Date, Population, new_vaccinations, RollingCountPeopleVaccinated)
AS (SELECT 
		dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
		SUM(CONVERT(vac.new_vaccinations, SIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingCountPeopleVaccinated
	FROM PortfolioProject.coviddeaths dea
	JOIN PortfolioProject.covidvaccinations vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL AND dea.continent <> ''
)
SELECT 
	Continent, Location, MAX(Date) AS LatestDate, MAX(RollingCountPeopleVaccinated) AS TotalVaccinated, MAX(Population) AS PopulationCount, 
	ROUND(MAX(RollingCountPeopleVaccinated) / MAX(Population) * 100, 2) AS VaccinatedPercent
FROM PopVsVacc
WHERE Population IS NOT NULL
GROUP BY Continent, Location
ORDER BY VaccinatedPercent, Continent;

SELECT * FROM PercentagePopulationVaccinated;

-- 
DROP TEMPORARY TABLE IF EXISTS TempPercentPopulationVaccinated;

CREATE TEMPORARY TABLE TempPercentPopulationVaccinated AS
WITH PopVsVacc AS (
    SELECT 
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS SIGNED)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM PortfolioProject.coviddeaths dea
    JOIN PortfolioProject.covidvaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL AND dea.continent <> ''
)
SELECT *
FROM PopVsVacc;

-- Getting the daily cumulative % vaccinated per country.
SELECT *, 
       ROUND((RollingPeopleVaccinated / population) * 100, 2) AS VaccinatedPercent
FROM TempPercentPopulationVaccinated
WHERE population IS NOT NULL
ORDER BY location, date;

-- Using Views to store data for future visualizations
CREATE OR REPLACE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS SIGNED)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.coviddeaths dea
JOIN PortfolioProject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> '';

SELECT * FROM PercentPopulationVaccinated
WHERE Location = 'Canada';