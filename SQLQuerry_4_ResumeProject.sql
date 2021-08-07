SELECT * FROM [Portfolio Project].dbo.CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT * FROM [Portfolio Project].dbo.CovidVaccinations
--ORDER BY 3,4

--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, population
From [Portfolio Project].dbo.CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likihood of dying from covid if you contract covid in a specific country at a specific point in time.

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage 
From [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total cases vs Population
-- Shows what percentage of the population got covid

SELECT location, date, total_cases, population, (total_cases/population) * 100 as percentpopulationInfected
From [Portfolio Project].dbo.CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
Where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- Showing the Counrties with the Highest Death Count per Population

Select location, MAX(cast (total_cases as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--where location like '%states%' 
where continent is not null
Group by location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing the continents with the highest death count per population

Select continent, MAX(cast (total_cases as int)) as TotalDeathCount
From [Portfolio Project].dbo.CovidDeaths
--where location like '%states%' 
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(New_cases) * 100 DeathPercentage  
From [Portfolio Project].dbo.CovidDeaths
--where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccinations 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
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
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

 -- Creating View to store data for later visualizations
 
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project].dbo.CovidDeaths dea
Join [Portfolio Project].dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

