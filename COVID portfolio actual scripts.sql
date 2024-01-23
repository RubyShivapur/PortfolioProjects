Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

-- Select Data that we are going to be using

Select Location, date,total_cases, new_cases,Total_deaths, Population
From PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths 

Select Location, date, total_cases,Total_deaths,(CONVERT(float,total_cases)/NULLIF(CONVERT(float,total_deaths),0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where location like '%States%'
order by 1,2


-- Shows likelihood of dying if you contract covid in your country 

Select Location, date,population, total_cases,Total_deaths,(CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%States%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%States%'
Group by  Location, Population
order by PercentPopulationInfected desc

-- Showing Countries with Highest Death count per population 

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
Group by  Location
order by TotalDeathCount desc

--LET'S BREAK THIS DOWN BY CONTINENT 


--Showing Continents with the Highest Death count per populatuion 

Select continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
Group by  continent
order by TotalDeathCount desc


--GLOBAL NUMBERS
---xxx--

Select date, total_cases,total_deaths,(CONVERT(float,total_cases)/NULLIF(CONVERT(float,total_deaths),0))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%States%'
Where continent is not null
Group By date 
order by 1,2
--xx--

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%States%'
Where continent is not null
Group By date 
order by 1,2

-- just to make sure it join properly 

Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date

   -- Looking at Total Population Vs Vaccinations


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed_per_million
,SUM(convert(int, vac.new_vaccinations_smoothed_per_million )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--. (RollingPeopleVaccinated / Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
order by 1,2

-- USE CTE

With PopvsVac (Continent, Location, Date, population, new_vaccinations_smoothed_per_million, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed_per_million
,SUM(convert(int, vac.new_vaccinations_smoothed_per_million )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--. (RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
   Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From popvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations_smoothed_per_million numeric,
 RollingPeopleVaccinated  numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed_per_million
,SUM(convert(int, vac.new_vaccinations_smoothed_per_million )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
  -- Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

CREATE VIEW  PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed_per_million
,SUM(convert(int, vac.new_vaccinations_smoothed_per_million )) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/Population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
  Where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated