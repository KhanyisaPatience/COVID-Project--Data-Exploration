
---Global data on confirmed  Covid-19 Deaths
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

--Looking for Total Cases vs Total Deaths
SELECT 
	location,
	date,
	population,
	total_cases,
	new_cases,
	total_deaths
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--Looking for Total Cases vs Total Deaths in South Africa(2)
SELECT 
	location,
	date,
	total_cases,
	total_deaths, 
CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%South Africa%'
	AND continent IS NOT NULL
ORDER BY 1,2

--Looking for Total Cases vs Population(3)
--Shows what percentage of population has Covid
SELECT 
	Location,
	date,
	Population,
	total_cases,
	CAST(total_cases AS float)/CAST(population AS float)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%South Africa%'
ORDER BY 1,2

--Global Percentage of Population that has Covid from HighestInfectedCount
SELECT
	Location,
	Population,
	MAX(CAST(total_cases AS float))AS HighestInfectedCount, 
	MAX(CAST(total_cases AS float)/CAST(Population AS float))*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
    --WHERE location LIKE '%South Africa%'
GROUP BY Location,Population
ORDER BY PercentagePopulationInfected DESC

--Showing Countries with Highest Death Count Per Population(4)
SELECT
	Location,MAX(cast(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
    --where location LIKE '%South Africa%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Showing Continent with Highest Death Count(5)
SELECT
	location,
	MAX(cast(total_deaths AS float)) AS TotalDeathCountByCountinent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location  NOT IN('World','Upper middle income','High income','lower middle income','Low income','European Union','International')
GROUP BY location
ORDER BY TotalDeathCountByCountinent DESC

--Lets break things down by continent
--Showing Continents with the Highest Deaths count per population

SELECT
	continent, 
	MAX(cast(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
    --where location LIKE '%South Africa%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS

SELECT
	date, 
	SUM(CAST(new_cases AS float)) AS total_cases, SUM(CAST(new_deaths AS float))AS total_deaths,
	SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

SELECT
	SUM(CAST(new_cases AS float)) AS total_cases, 
	SUM(CAST(new_deaths AS float))AS total_deaths,
	SUM(CAST(new_deaths AS float))/SUM(CAST(new_cases AS float))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
    --group by date
ORDER BY 1,2

--Looking at Total Population vs Vaccination
--Rolling numbers of people vaccinated
SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population
FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
ORDER BY 2,3

--USE CTE

With PopvsVac (Continent,Location,Date,Population,New_vacinnations,RollingPeopleVaccinated)
AS
	(
SELECT 
	dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)
FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS  NOT NULL
	--order by 2,3
	)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentagePopulationVaccinated
SELECT 
	dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)
FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
	--where dea.continent is not null
	--order by 2,3
SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentagePopulationVaccinated

--Creating Views to store data for later  visualization
--View 1

USE PortfolioProject
GO
CREATE VIEW PercentagePopulationVaccinated AS
SELECT 
	dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
	SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)
FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
	--order by 2,3
GO

SELECT *
FROM PercentagePopulationVaccinated


--View 2
--Looking for Total Cases vs Total Deaths in South Africa(2)

USE PortfolioProject
GO
CREATE VIEW DeathPercentage AS
SELECT 
	location,date,total_cases,total_deaths, CAST(total_deaths AS float)/CAST(total_cases AS float)*100 AS DeathPercentage
	FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%South Africa%'
	AND continent IS NOT NULL
--ORDER BY 1,2
GO

--View 3
--Looking for Total Cases vs Population(3)
--Shows what percentage of population has Covid

USE PortfolioProject
GO
CREATE VIEW PercentagePopulationInfected AS
SELECT
	location,date,Population,total_cases, CAST(total_cases as float)/CAST(population as float)*100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE '%South Africa%'
--ORDER BY 1,2
GO

--View 4
--Showing Countries with Highest Death Count Per Population(4)

USE PortfolioProject
GO
CREATE VIEW  TotalDeathCount AS
SELECT 
	location,MAX(cast(total_deaths AS float)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
	--where location LIKE '%South Africa%'
WHERE continent IS NOT NULL
GROUP BY Location
--ORDER BY TotalDeathCount DESC
GO

USE PortfolioProject
GO
CREATE VIEW TotalDrathCountByContinent AS
SELECT
	location,
	MAX(cast(total_deaths AS float)) AS TotalDeathCountByCountinent
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
AND location  NOT IN('World','Upper middle income','High income','lower middle income','Low income','European Union','International')
GROUP BY location
--ORDER BY TotalDeathCountByCountinent DESC
GO