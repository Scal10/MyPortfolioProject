--                          COVID WORLD DATA AS AT JULY, 2022.

SELECT *
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE continent IS NOT NULL
    ORDER BY 2

-- Starting with the data below
SELECT location, date, total_cases, new_cases, total_deaths, population
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE continent IS NOT NULL
    ORDER BY 1

-- Lets examine total_cases against total_deaths
-- Shows the estimate of Death Percentage in the UK

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS 'death percentage'
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE location LIKE '%kingdom%' AND continent is NOT NULL
    ORDER BY 2 DESC

-- Examining the Total cases by Population
-- Shows what percentage of population with covid in the UK

SELECT location, date, population, total_cases, (total_cases/population)*100 as 'Infected Percentage'
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE location LIKE '%kingdom%'
    order by 5 DESC

-- Countries with highest infection rate compared to Population

SELECT location, population, MAX(total_cases) AS 'Highest infection count', 
MAX((total_cases/population))*100 as 'Infected Population Percentage'
    FROM PortfolioProject.dbo.[Covid Deaths]
    -- WHERE location LIKE '%kingdom%'
    GROUP BY location, population
    ORDER BY 1

-- Showing Countries with highest infection count

SELECT location, MAX(total_cases) AS 'Highest infection count'
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE continent IS NOT NULL
    GROUP BY location
    ORDER BY 2 DESC

-- Countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths as int)) AS 'Total death count'
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE continent IS NOT NULL
    GROUP BY location
    ORDER BY 'Total death count' DESC

-- By continent

-- Showing Continents with the highest death count per population

SELECT continent, SUM(CAST(new_deaths as int)) AS 'Total death count'
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE continent IS NOT NULL
    GROUP BY continent
    ORDER BY 'Total death count' DESC

-- Continents according to their infection count

SELECT continent, MAX(total_cases) AS 'Highest infection count'
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE continent IS NOT NULL
    GROUP BY continent
    ORDER BY 2 DESC

-- World numbers
-- World COVID cases by date

SELECT date, MAX(total_cases) AS 'World total cases', MAX(CAST(total_deaths as int)) AS 'World total deaths', 
MAX(CAST(total_deaths as int))/MAX(total_cases) *100 AS 'death percentage'
    FROM PortfolioProject.dbo.[Covid Deaths]
    -- WHERE continent is NOT NULL
    GROUP BY date
    ORDER BY 1

-- World numbers in total

SELECT SUM(new_cases) AS 'total cases', SUM(CAST(new_deaths as int)) AS 'total deaths', 
SUM(CAST(new_deaths as int))/SUM(new_cases) *100 AS 'death percentage'
    FROM PortfolioProject.dbo.[Covid Deaths]
    WHERE continent IS NOT NULL
    -- GROUP BY total_cases
    ORDER BY 1 DESC


-- Covid Vaccinations
-- Lets examine the total population against vaccinations

-- Showing the daily vaccinations in the United Kingdom since 2021

SELECT cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations
    FROM PortfolioProject.dbo.[Covid Deaths] cd
    JOIN PortfolioProject.dbo.[Covid Vaccinations] cv
    ON cd.date = cv.date AND cd.location = cv.location
    WHERE cd.continent IS NOT NULL AND cd.location LIKE '%kingdom%' AND cd.date > '2021-01-01'
    ORDER BY 1

-- Total doses across countries since 2021
    SELECT cd.date, cd.location, cd.population, SUM(cv.total_vaccinations) as 'Total Doses'
    FROM PortfolioProject.dbo.[Covid Deaths] cd
    JOIN PortfolioProject.dbo.[Covid Vaccinations] cv
    ON cd.date = cv.date AND cd.location = cv.location
    WHERE cd.continent IS NOT NULL AND cd.date > '2021-01-01'
    --AND cv.total_vaccinations IS NOT NULL
    Group by cd.date, cd.location, cd.population
    ORDER BY 2, 1

-- Total Population vs vaccinations
-- Showing percentage of population that has received at least one Vaccine

    SELECT cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.LOCATION ORDER BY cd.location, cd.date) AS 'Rolling Over Vaccinations'
    FROM PortfolioProject.dbo.[Covid Deaths] cd
    JOIN PortfolioProject.dbo.[Covid Vaccinations] cv
    ON cd.date = cv.date AND cd.location = cv.location
    WHERE cd.continent IS NOT NULL
    ORDER BY 3,1


-- Let's use CTE (Common Table Expression) and TEMP Table to perform calculation on Partition By in previous query
-- CTE

WITH PopulationVsVaccinations (date, continent,location,population, new_vaccinations, RollingOverVaccinations) 
AS 
(SELECT cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.LOCATION ORDER BY cd.location, cd.date) AS 'Rolling Over Vaccinations'
    FROM PortfolioProject.dbo.[Covid Deaths] cd
    JOIN PortfolioProject.dbo.[Covid Vaccinations] cv
    ON cd.date = cv.date AND cd.location = cv.location
    WHERE cd.continent IS NOT NULL)
    --ORDER BY 3,1
SELECT *, (RollingOverVaccinations/population) * 100 AS 'Vaccination Percentage'
FROM PopulationVsVaccinations

-- Temp Table

DROP TABLE IF EXISTS #PercentageofPopulationVaccinated
CREATE TABLE #PercentageofPopulationVaccinated
(date date, Continent nvarchar(255), Location nvarchar(255), Population float,
new_vaccinations float, RollingOverVaccinations float)

INSERT INTO #PercentageofPopulationVaccinated
SELECT cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations,
SUM(cv.new_vaccinations) OVER (PARTITION BY cd.LOCATION ORDER BY cd.location, cd.date) AS 'Rolling Over Vaccinations'
    FROM PortfolioProject.dbo.[Covid Deaths] cd
    JOIN PortfolioProject.dbo.[Covid Vaccinations] cv
    ON cd.date = cv.date AND cd.location = cv.location
    WHERE cd.continent IS NOT NULL
    --ORDER BY 3,1

SELECT *, (RollingOverVaccinations/population) * 100 AS 'Vaccination Percentage'
FROM #PercentageofPopulationVaccinated
ORDER BY 3,1

-- Creating view to store data for visualisations
CREATE VIEW PercentageofPopulationVaccinated AS
    SELECT cd.date, cd.continent, cd.location, cd.population, cv.new_vaccinations,
    SUM(cv.new_vaccinations) OVER (PARTITION BY cd.LOCATION ORDER BY cd.location, cd.date) AS 'Rolling Over Vaccinations'
    FROM PortfolioProject.dbo.[Covid Deaths] cd
    JOIN PortfolioProject.dbo.[Covid Vaccinations] cv
    ON cd.date = cv.date AND cd.location = cv.location
    WHERE cd.continent IS NOT NULL
    --ORDER BY 3,1

SELECT *
FROM PercentageofPopulationVaccinated
