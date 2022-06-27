select *
from PortfolioProject1..CovidDeaths
order by 3,4

--select *
--from PortfolioProject1..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
select Location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject1..CovidDeaths
order by 1,2

-- Looking at Total cases vs Total Deaths
-- Shows the likelihood of dying ig you contract covid in the United States
select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercent
from PortfolioProject1..CovidDeaths
Where location = 'United States'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select Location, date, total_cases,population,(total_cases/population)*100 as Infectedpercent
from PortfolioProject1..CovidDeaths
Where location = 'United States'
order by 1,2

-- Looking at countries with highest infection rate compared to population
select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject1..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--Showing the countries with the Highest Death count per population
select Location,Max(cast(total_deaths as int)) as DeathCount
from PortfolioProject1..CovidDeaths
where continent is not null
group by Location
order by DeathCount desc

--Breakingthings down by continent
select location,Max(cast(total_deaths as int)) as DeathCount
from PortfolioProject1..CovidDeaths
where continent is null
group by location
order by DeathCount desc

--GLOBAL NUMBERS
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject1..CovidDeaths
-- where location like '%states'
where continent is not null
--group by date
order by 1,2


-- VACCINATIONS
select *
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location,dea.Date)
as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

-- USE CTE
With PopVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location,dea.Date)
as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)
Select *,(RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from PopVac


-- SAME THING USING A TEMP TABLE

Create Table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

DROP TABLE if exists #PercentPopulationVaccinated

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location,dea.Date)
as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *,(RollingPeopleVaccinated/Population)*100 as PercentPopulationVaccinated
from #PercentPopulationVaccinated




-- Creating a view to store data for later visualizations
Create View PercentPopulationVaccinated as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) Over (Partition by dea.location order by dea.location,dea.Date)
as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths dea
join PortfolioProject1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 
)

Select * from PercentPopulationVaccinated 