SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

	--For later..
	--select *
	--from PortfolioProject..CovidVaccinations
	--order by 3,4


-- Select Data that we are going to be using 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2



--Looking at Total Cases vs Total Deaths
	-- Shows likelihood of dying if you contract covid in youre coutry
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
	-- Shows what percentage of population got Covid 
SELECT location, date, Population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
	--where location like '%states%'
ORDER BY 1,2



-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
	--where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
	--WHERE location LIKE '%states%'
GROUP BY continent
ORDER BY TotalDeathCount DESC



--GLOBAL NUMBERS
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths 
	--WHERE location like '%states%'
WHERE continent IS NOT NULL
	--GROUP BY date
ORDER BY 1,2



--Looking at total population vs Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



--Use CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(	
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) 
	OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



--TEMPORARY TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollngPeopleVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	--WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *, (RollngPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for visualizations
CREATE VIEW PercentPopulationVaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(INT, vac.new_vaccinations)) 
		OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated