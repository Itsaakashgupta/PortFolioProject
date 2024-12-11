Select *
From Port_folio_project.dbo.CovidDeaths

---Select *
---From Port_folio_project.dbo.Vaccination
---Order By 3,4

--- Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population 
From Port_folio_project.dbo.CovidDeaths
Order By 1, 2

--- Looking at Total Cases vs Total Deaths
--- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths,
   Round(((total_deaths/total_cases)*100),2) as death_percentage
From Port_folio_project.dbo.CovidDeaths
Where location like '%states%'
 AND continent IS NOT NULL
Order By 1, 2

--- Looking at Total Cases vs Population
--- Shows what percentage of population got Covid
Select Location, date, population, total_cases,
   Round(((total_cases/population)*100),2) as percent_population_infected
From Port_folio_project.dbo.CovidDeaths
---Where location like '%states%'
Where continent IS NOT NULL
Order By 1, 2


--- Looking at Countries with Highest Infection Rate compared to Population 
Select Location, population, Max(total_cases) As highest_infection_count,
    Max((total_cases/population)*100) As percent_population_infected
From Port_folio_project.dbo.CovidDeaths
--- Where location like '%states%'
Where continent IS NOT NULL
Group By Location, population
Order By percent_population_infected desc


--- Showing Countries with Highest Death Count per Population
Select Location, Max(Cast(total_deaths as INT)) As total_death_count
From Port_folio_project.dbo.CovidDeaths
--- Where location like '%states%'
Where continent IS NOT NULL
Group By Location
Order By total_death_count desc

--- Let's break things by continenet
--- Showing continent by highest number of death counts
Select Continent, Max(Cast(total_deaths as INT)) As total_death_count
From Port_folio_project.dbo.CovidDeaths
--- Where location like '%states%'
Where continent IS NOT NULL
Group By continent
Order By total_death_count desc

---  Global Numbers

Select sum(new_cases) as total_cases, Sum(cast(new_deaths as INT)) as total_deaths,
   sum(cast(new_deaths as INT))/sum(new_cases)*100 as death_percentage
From Port_folio_project.dbo.CovidDeaths
--- Where location like '%states%'
Where continent IS NOT NULL
--- Group by date
Order By 1, 2

--- From vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Port_folio_project..CovidDeaths as dea
Join Port_folio_project..Vaccination as vac
   ON dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent IS NOT NULL
Order By 2,3

--- Looking at total population vs vaccination


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   Sum(cast(vac.new_vaccinations as INT)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_pople_vaccinated
   --- , (rolling_people_vaccinated/population)*100
From Port_folio_project..CovidDeaths as dea
Join Port_folio_project..Vaccination as vac
   ON dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent IS NOT NULL
Order By 2,3


-- USE CTE
With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   Sum(cast(vac.new_vaccinations as INT)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_pople_vaccinated
   --- , (rolling_people_vaccinated/population)*100
From Port_folio_project..CovidDeaths as dea
Join Port_folio_project..Vaccination as vac
   ON dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent IS NOT NULL
---Order By 2,3
)
Select *, (rolling_people_vaccinated/population)*100
From pop_vs_vac


--- Temp Table

DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   Sum(cast(vac.new_vaccinations as INT)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_pople_vaccinated
   --- , (rolling_people_vaccinated/population)*100
From Port_folio_project..CovidDeaths as dea
Join Port_folio_project..Vaccination as vac
   ON dea.location = vac.location
   AND dea.date = vac.date
---Where dea.continent IS NOT NULL
---Order By 2,3

Select *, (rolling_people_vaccinated/population)*100
From #percent_population_vaccinated


--- Creating view to store data for later visulization

CREATE VIEW percent_people_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
   Sum(cast(vac.new_vaccinations as INT)) OVER (partition by dea.location order by dea.location, dea.date) as rolling_pople_vaccinated
   --- , (rolling_people_vaccinated/population)*100
From Port_folio_project..CovidDeaths as dea
Join Port_folio_project..Vaccination as vac
   ON dea.location = vac.location
   AND dea.date = vac.date
Where dea.continent IS NOT NULL
---Order By 2,3

SELECT *
From percent_people_vaccinated
