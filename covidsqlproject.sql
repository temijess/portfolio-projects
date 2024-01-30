select *
from PortfolioProjects..CovidDeaths$
order by 3,4;



--select *
--from PortfolioProjects..CovidVaccinations$
--order by 3, 4;

--select data to use
select location, date, total_cases, total_deaths,new_cases, population
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 1,2;

--shows likelihood of dying if you contact covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  as Percentage
from PortfolioProjects..CovidDeaths$
where continent is not null and location like '%Nigeria%'
order by 1,2;


--total cases vs population, shows percentage poplatio affected by covid
select Location, date, total_cases, population, (total_cases/population)*100  as PercentageInfected
from PortfolioProjects..CovidDeaths$
where continent is not null
order by 1,2;

--country with highest rate of infection compared to population
select Location, population, MAX(total_cases) AS HighestInfected, Max((total_cases/population))*100  as HighestPercentageInfectedPopulation
from PortfolioProjects..CovidDeaths$
where continent is not null
group by location, population
order by HighestPercentageInfectedPopulation DESC;

--country with highest rate of deaths
select location, MAX(cast(total_deaths as int)) AS deathcount
from PortfolioProjects..CovidDeaths$
where continent is not null
group by location
order by deathcount DESC;

--break into continents
select continent, MAX(cast(total_deaths as int)) AS ContinentalDeathcount
from PortfolioProjects..CovidDeaths$
where continent is not null
group by continent
order by ContinentalDeathcount DESC;

--global calculations
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100  as DeathPercentage
from PortfolioProjects..CovidDeaths$
where continent is not null
group by date
order by 1,2;


--joining death and vaccination tables
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--creating a temp table 
drop table if exists percentagePopulationVaccinated
create table percentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into percentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100 as percentage_pop_vaccinated
from percentagePopulationVaccinated;


Create View PopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProjects..CovidDeaths$ dea
join PortfolioProjects..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null;

select *
from PopulationVaccinated;

