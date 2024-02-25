select * from [PortfolioProject].[dbo].[CovidDeaths] where continent is not null order by 3,4 

--Select data we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [PortfolioProject].[dbo].[CovidDeaths]
order by 1,2

--Looking at total cases vs total deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
where location = 'India'
order by 1,2

--Looking at total cases vs population
--Shows what percentage of population got covid
SELECT location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
where location = 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population

SELECT location,population,MAX(total_cases) as  HighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
group by location,population
order by 4 desc

--Showing countries with highest death count

SELECT location,MAX(cast(total_deaths as int)) as  HighestDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
where continent is not null
group by location,population
order by 2 desc

--Showing continent with the highest death count per population

SELECT continent,MAX(cast(total_deaths as int)) as  HighestDeathCount
FROM [PortfolioProject].[dbo].[CovidDeaths]
where continent is not null
group by continent
order by 2 desc

--Global Numbers

SELECT sum(new_cases) total_Cases ,sum(cast(new_deaths as int)) total_Deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
where continent is not null
--group by date
order by 1,2

--Looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from [PortfolioProject].[dbo].[CovidDeaths] dea
join [PortfolioProject].[dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--Using CTE

with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from [PortfolioProject].[dbo].[CovidDeaths] dea
join [PortfolioProject].[dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),location nvarchar(255),date datetime,population numeric,New_Vaccinations numeric,RollingPeopleVaccinated numeric)
insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from [PortfolioProject].[dbo].[CovidDeaths] dea
join [PortfolioProject].[dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating views to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) RollingPeopleVaccinated
from [PortfolioProject].[dbo].[CovidDeaths] dea
join [PortfolioProject].[dbo].[CovidVaccinations] vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

 