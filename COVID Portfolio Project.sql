/*
Covid 19 Data Exploration 
Skills used: Joins, Temp Tables, Aggregate Functions, Creating Views, Converting Data Types (cast, convert)
*/

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4



-- Select Data to be starting with

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2




--- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if contracted covid by country

select location, date, total_cases, total_deaths, (convert (numeric(18,2), total_deaths)/convert (numeric(18,2), total_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%ndia%'
and continent is not null
order by 1,2




--- Looking at Total Cases vs Population
--- Shows what percentage of population got Covid

select location, date,  population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%ndia%'
order by 1,2




-- Looking at Countries with Highest Infection Rate compared to Population

select location, population, MAX(cast(total_deaths as int)) as HighestInfectionCount, Max((cast(total_deaths as int)/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like '%ndia%'
group by location, population
order by PercentPopulationInfected desc




-- Showing countries with highest Death Count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%ndia%'
where continent is not null
group by location
order by TotalDeathCount desc





-- Breaking down by continent

-- Showing the continents with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like '%ndia%'
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%ndia%'
where continent is not null
group by date
order by 1,2




-- Looking at Total Populations vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3





-- Using Temp Table to perform Calculation on Partition By in previous query


drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated





-- Creating view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated
