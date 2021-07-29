SELECT  *
FROM Covidproject..CovidDeath
Where continent is not null
Order by 3,4

--SELECT  *
--FROM Covidproject..CovidVaccination
--Order by 3,4


Select Location,date,total_cases,new_cases,total_deaths,population
From Covidproject..CovidDeath
order by 1,2

-- looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract in India

Select Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Covidproject..CovidDeath
Where location  ='India' 
order by 1,2

--Looking at Total cases Vs Population
-- show waht percenatge got Covid
Select Location,date,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From Covidproject..CovidDeath
--Where location  ='India'
order by 1,2

--Looking at Countries with Highest Infection rate compared to population
Select Location,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
From Covidproject..CovidDeath
--Where location  ='India'
Group by Location,population
order by PercentPopulationInfected desc

Select Location, date,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population)*100) as PercentPopulationInfected
From Covidproject..CovidDeath
--Where location  ='India'
Group by Location,population,date
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Popullation
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Covidproject..CovidDeath
Where continent is not null
--Where location  ='India'
Group by Location
order by TotalDeathCount desc


-- Let's Break things by location
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From Covidproject..CovidDeath
Where continent is null
--Where location  ='India'
Group by Location
order by TotalDeathCount desc


--Showing the continent with highest death count per population

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From Covidproject..CovidDeath
Where continent is not null
--Where location  ='India'
Group by continent
order by TotalDeathCount desc




--Global numbers (new cases on each day)
Select date, SUM(new_cases) as total_new_cases,SUM(cast(new_deaths as int)) as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Covidproject..CovidDeath
Where continent is not null
Group by date
order by 1,2

Select  SUM(new_cases) as total_new_cases,SUM(cast(new_deaths as int)) as total_new_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Covidproject..CovidDeath
Where continent is not null
--Group by date
order by 1,2




--Looking at Total Population vs vaccination

Select*
From Covidproject..CovidDeath dea
Join Covidproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date


Select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
From Covidproject..CovidDeath dea
Join Covidproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3

-- partition by does rolling count
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location ORDER by dea.location,dea.date) As RollingPeopleVaccinated
From Covidproject..CovidDeath dea
Join Covidproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE to use RollingPeopleVaccinated
With PopVsVac(Continent,location,date,population,RollingPeopleVaccinated,new_vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location ORDER by dea.location,dea.date) As RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From Covidproject..CovidDeath dea
Join Covidproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select* ,(RollingPeopleVaccinated/population)*100
From PopVsVac



--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPopulationVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location ORDER by dea.location,dea.date) As RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From Covidproject..CovidDeath dea
Join Covidproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*, (RollingPopulationVaccinated/Population)*100
From #PercentPopulationVaccinated


 
 -- creating view data for later visulaization

 Create View PercentPopulationVaccinated as
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) Over (Partition by dea.location ORDER by dea.location,dea.date) As RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From Covidproject..CovidDeath dea
Join Covidproject..CovidVaccination vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
Select *
From PercentPopulationVaccinated
