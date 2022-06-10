SELECT * 
FROM CovidDeaths
WHERE continent is not null
ORDER BY 3 , 4 

SELECT *
FROM CovidVaccinations
WHERE continent is not null
ORDER BY 3 , 4 

-- Select Data that we are going to be using

SELECT location,date, total_cases, new_cases,total_deaths,population
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1 , 2 


-- Looking at Total Cases vs Total Deaths
-- Shows the death rate of Covid in the country

SELECT location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
-- WHERE location like '%Saudi%'
ORDER BY 1 , 2 


-- Looking at Total Cases vs Population
-- Shows what  percentage of population got Covid

SELECT location,date, population, total_cases,(total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
-- WHERE location like '%Saudi%'
ORDER BY 1 , 2 


-- Looking at countries with Highest Infection Rate Compared to Population 

SELECT location, population, Max(total_cases) AS HighestInfectionCount , MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP By location, population
ORDER BY  PercentPopulationInfected DESC


-- Showing the Countries with Highest Death Count per Population 

SELECT location, MAX(CAST(total_deaths AS Int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP By location
ORDER BY TotalDeathCount DESC 


-- Let's BREAK THINGS DOWN BY CONTINENT !!
-- Showing Continents with Highest Death Count per population 

SELECT continent, MAX(CAST(total_deaths AS Int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP By continent
ORDER BY TotalDeathCount DESC 


-- Global Numbers 

SELECT  
-- date,
SUM(new_cases) AS totalCases, SUM(CAST(new_deaths AS int)) AS totalDeath
,SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
-- WHERE location like '%Saudi%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population VS Vaccinations
-- In other way is The Total amount of people in world who have been vaccinated 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location 
 ,dea.date) AS RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE 

WITH PopvsVac(continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location 
 ,dea.date) AS RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3
)
SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- Temp Table 

IF OBJECT_ID('#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;
GO
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location 
 ,dea.date) AS RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date
-- WHERE dea.continent is not null
-- ORDER BY 2,3

SELECT * ,(RollingPeopleVaccinated/Population)*100
FROM  #PercentPopulationVaccinated



-- Creating View to store data for later visualization 

CREATE View PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location 
 ,dea.date) AS RollingPeopleVaccinated
 --,(RollingPeopleVaccinated/dea.population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent is not null
-- ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated