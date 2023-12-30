----Data we are going to be using
--Select location, date, total_cases, new_cases, total_deaths, population
--From PortfolioProject..CovidDeaths
--Order by location, date

---- Total cases vs Deaths
---- Likelihood of dying from COVID, Hungary
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercent
--From PortfolioProject..CovidDeaths
--Where location like '%hun%'
--Order by 1,2

---- Total cases vs Population, Hungary
--Select location, date, total_cases, population, (total_cases/population)*100 as PopPercent
--From PortfolioProject..CovidDeaths
--Where location like '%hun%'
--Order by 1,2

--Infectionrate
--Select location, population, MAX(total_cases) as HighestCaseCount, MAX((total_cases/population))*100 as InfectionRate
--From PortfolioProject..CovidDeaths
--Where population is not NULL and total_cases is not Null
--Group by location, population
----Order by InfectionRate desc

---- Death rate per population
--Select location, (MAX(cast(total_deaths as int))) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathRate
--From PortfolioProject..CovidDeaths
--Where population is not NULL and total_deaths is not Null and continent is not NULL
--Group by location
--Order by HighestDeathCount desc

-- CONTINENT BREAKDOWNS
-- Proper breakdown because when a Continent is the Location, Continent column will be NULL
-- Thus filtering for NULL continent but using Location gives accurate Continent results
-- Portfolio project will operate with not null values to preserve training cohesion
--Select location, (MAX(cast(total_deaths as int))) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathRate
--From PortfolioProject..CovidDeaths
--Where population is not NULL and total_deaths is not Null and continent is NULL
--Group by location
--Order by HighestDeathCount desc

---- Continents with Highest DeathCount per Population
--Select continent, (MAX(cast(total_deaths as int))) as HighestDeathCount, MAX((total_deaths/population))*100 as DeathRate
--From PortfolioProject..CovidDeaths
--Where population is not NULL and total_deaths is not Null and continent is not NULL
--Group by continent
--Order by HighestDeathCount desc

-- GLOBAL NUMBERS
--Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
--Where continent is not NULL
--Group by date
--Order by 1,2

--Total pop vs Vac
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.Date) as TotalVacRolling
--From PortfolioProject..CovidDeaths as dea
--Join PortfolioProject..CovidVaccinations as vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not Null
--order by 2,3

-- CTE
--With PopvsVac (continent, location, date, population, new_vaccinations, TotalVacRolling)
--as
--(
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.Date) as TotalVacRolling
--From PortfolioProject..CovidDeaths as dea
--Join PortfolioProject..CovidVaccinations as vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not Null
--)
--Select *, (TotalVacRolling/population)*100 as PopsVacRatio
--From PopvsVac

-- TempTable

--Drop Table if exists #temp_PopvsVac
--Create table #temp_PopvsVac
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--TotalVacRolling numeric
--)

--Insert into #temp_PopvsVac
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
--SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.Date) as TotalVacRolling
--From PortfolioProject..CovidDeaths as dea
--Join PortfolioProject..CovidVaccinations as vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not Null

--Select *, (TotalVacRolling/population)*100 as PopsVacRatio
--From #temp_PopvsVac

-- Creating view for later
Create view PopvsVac as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) Over (Partition by dea.location Order by dea.location, dea.Date) as TotalVacRolling
From PortfolioProject..CovidDeaths as dea
Join PortfolioProject..CovidVaccinations as vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not Null