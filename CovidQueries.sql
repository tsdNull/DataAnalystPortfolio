-- Looking at % of cases as deaths
-- Shows likelihood of UK citizens dying from Covid 
Select Location, date, continent, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where location like '%kingdom%'
order by 1,2

-- Looking for highets infection rate compared to population

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopInfected
FROM PortfolioProject.dbo.CovidDeaths
Group by Location, Population
order by PercentPopInfected desc

-- Showing countries with highest death count per population.

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Show as continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc

-- Global numbers, for drilling down to use in visualisation
Select date, SUM(new_cases), SUM(cast(new_deaths as int)), SUM(CONVERT(int, new_deaths)) /SUM(new_cases)*100 as DeathPercentage--continent, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--Where location like '%kingdom%'
Where continent is not null
Group by date
order by 1,2

--Overall global numbers
Select SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int)) /SUM(new_cases)*100 as DeathPercentage--continent, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
Where continent is not null
order by 1,2;

-- CTE EXAMPLE
With PopVsVax (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
-- Looking at total pop VS vaxed rate
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as int)) OVER (Partition by deaths.Location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null

)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVax

-- TEMP TABLE EXAMPLE
DROP TABLE if exists #PercentPopVaxxed
CREATE TABLE #PercentPopVaxxed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopVaxxed
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as int)) OVER (Partition by deaths.Location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null
order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopVaxxed

-- Creating Views for visualisations
GO
Create View PercentPopVaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations, SUM(cast(vax.new_vaccinations as int)) OVER (Partition by deaths.Location Order by deaths.location, deaths.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths deaths
JOIN PortfolioProject..CovidVaccinations vax
	on deaths.location = vax.location
	and deaths.date = vax.date
where deaths.continent is not null