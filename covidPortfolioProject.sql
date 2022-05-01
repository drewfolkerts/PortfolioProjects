
-- Select  Data that we are going to be using
SELECT location, date, total_cases, new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in united states
SELECT location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage got covid
SELECT location, date, total_cases,population,(total_cases/population)*100 as CovidPercentage
FROM PortfolioProject..CovidDeaths
Where continent is not null
order by 1,2

--Highest infection rate compared to population
SELECT location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death rate
SELECT location,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount desc

--Deathcount by Continent
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers
SELECT date,SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths , (SUM(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2
--Global total cases,deaths, and percentage
SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as total_deaths , (SUM(cast(new_deaths as int))/sum(new_cases))*100 as Death_Percentage
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--Looking at Total population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--use cte
With PopvsVac (continent,location,date,population,newvaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store later data for later visualization

create view PercentPopulationVaccinated AS 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date)as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated

