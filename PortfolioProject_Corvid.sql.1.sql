/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
--we view our tables using
Select *
From PortfolioProject..CovidDeaths
Order by 3,4

-- Select Data that we are going to be starting with
SELECT Location, date, total_cases, new_cases, total_deaths, population 
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Shows likelihood of dying if you contract covid
SELECT Location, total_cases, total_deaths, (CAST(total_deaths AS decimal)/CAST(total_cases AS decimal))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal)/CAST(total_cases AS decimal))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%kenya%'
AND continent IS NOT NULL
ORDER BY 1,2 

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Shows what percentage of population infected with Covid in kenya
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%kenya%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PopulationPercentageInfected
FROM PortfolioProject..CovidDeaths
GROUP BY Location, population
ORDER BY PopulationPercentageInfected DESC;

-- Countries with Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS int))AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int))AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

--to get better accuracy include continent values and group by Location
SELECT Location, MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY Location
ORDER BY HighestDeathCount DESC;

---- GLOBAL NUMBERS

SELECT date, SUM(CAST(new_cases AS decimal)) AS total_cases, SUM(cast(new_deaths AS decimal)) AS total_deaths, (SUM(CAST(new_deaths as decimal))/SUM(CAST(new_cases AS decimal)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2;

--Total GLOBAL NUMBERS PERCENTAGE DEATHS
SELECT SUM(CAST(new_cases AS decimal)) AS total_cases, SUM(cast(new_deaths AS decimal)) AS total_deaths, (SUM(CAST(new_deaths as decimal))/SUM(CAST(new_cases AS decimal)))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2;

-- Total Population vs Vaccinations
SELECT dea.date, dea.location, dea.continent, dea.population, vac.new_vaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT dea.date, dea.location, dea.continent, dea.population, vac.new_vaccinations, 
          SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location)
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
          SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
          SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
		 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--oR

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
  (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
          SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac;


--OR USING CONVERT

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

--WITH TEMP TABLE

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
          SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
          SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated;


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
          SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		 --(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3

Select *
From PercentPopulationVaccinated


/*CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.date, dea.location, dea.continent, dea.population, vac.new_vaccinations, 
          SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location) AS VACCINATED
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
   ON dea.location = vac.location
   AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3*/




-- Creating View to store data for later visualizations

/*Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null*/