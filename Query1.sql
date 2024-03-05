/*
Covid-19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--Glimpse of the Entire CovidVaccinations dataset
select * from SQLProject1.dbo.CovidVaccinations

--Glimpse of the Entire CovidDeaths dataset
select * from SQLProject1.dbo.CovidDeaths


select location, date , total_cases,new_cases,total_deaths,population
from SQLProject1.dbo.CovidDeaths

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date , total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from SQLProject1.dbo.CovidDeaths
where location='India'

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid 
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
from SQLProject1.dbo.CovidDeaths

-- Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
from SQLProject1.dbo.CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from SQLProject1.dbo.CovidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Contintents with the highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from SQLProject1.dbo.CovidDeaths
Where continent is  null 
Group by Location
order by TotalDeathCount desc

-- Death's in world due to covid
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from SQLProject1.dbo.CovidDeaths
where continent is not null 
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
from SQLProject1.dbo.CovidDeaths dea
Join  SQLProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
from SQLProject1.dbo.CovidDeaths dea
Join  SQLProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (TotalPeopleVaccinated/Population)*100 as Percentage_TotalPeopleVaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as TotalPeopleVaccinated
from SQLProject1.dbo.CovidDeaths dea
Join  SQLProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (TotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View people_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from SQLProject1.dbo.CovidDeaths dea
Join  SQLProject1.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


