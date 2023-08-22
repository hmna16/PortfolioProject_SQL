select *
from PortfolioProject..CovidDeaths
where continent is not null
order by location, date

--select *
--from PortfolioProject..CovidVaccinations
--order by location, date

-- retrieve only necessary columns needed for now from Coviddeaths table

select location, date, population, total_cases, new_cases, total_deaths
from PortfolioProject..CovidDeaths
order by location, date

-- for my home country (Pakistan), when was the first case and first death reported?

select location, date, population, total_cases, new_cases, total_deaths
from PortfolioProject..CovidDeaths
where location like '%Pakistan%'
order by date;

-- when was the highest death recorded?

select location, date, total_cases, total_deaths
from PortfolioProject..CovidDeaths
where location like '%Pakistan%'
order by total_deaths desc


--compare total cases with total deaths and show new column as death_percentage

select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as DeathPercentage
from dbo.CovidDeaths$
where location like '%Pakistan%'
order by location, date


-- Comparing total cases with population to identify what percentage of population contracted this deadly disease

select location, date, total_cases, population, ((total_cases/population)*100) as AffectedPopulationPercentage
from dbo.CovidDeaths$
where location like '%Pakistan%'
order by date


select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population)*100) as AffectedPopulationPercentage
from dbo.CovidDeaths$
where location like '%Pakistan%'
group by location, population


--Look into countries with the highest infection rates compared to their population

select location, max(total_cases) as HighestInfectionCount, population, max((total_cases/population)*100) as AffectedPopulationPercentage
from dbo.CovidDeaths$
group by location, population
order by AffectedPopulationPercentage desc

--Look into countries with the highest death count compared to their population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

-- Find which continents has how many death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc

-- Now, we need data globally

select date,sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths
from PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by total_deaths desc

-- let's find death percentage to the above query

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null 
--group by date
order by 1,2

--combining two tables: CovidDeaths and CovidVaccinations

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- how many people got vaccinated compared to the population

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null and dea.location = 'Pakistan'
order by 2,3

-- use window function 

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- use cte

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
)
select *, (RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
from PopvsVac


-- Temp Table

drop table if exists #PercentPoplationVaccinated
Create Table #PercentPoplationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPoplationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
-- where dea.continent is not null 

select *, (RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
from #PercentPoplationVaccinated



-- create view to store data for later visualization in Tableau

create view View_PercentPoplationVaccinated as

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 


select *
from New_PercentPoplationVaccinated














