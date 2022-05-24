Select *
From Portfolio_Project1..covid_death
Where continent is not null
order by 3,4

--Select *
--From Portfolio_Project1..covid_vaccination
--order by 3,4

Select location, date, population, total_cases, new_cases, total_deaths
From Portfolio_Project1..covid_death
Where continent is not null
order by 1,2


-- Total Deaths Vs Total Cases

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From Portfolio_Project1..covid_death
Where location like '%India'
and continent is not null
order by 1,2


-- Total Cases Vs Population

Select location, date, population, total_cases, (total_cases/population)*100 AS InfectedPercentage
From Portfolio_Project1..covid_death
Where location like '%India'
and continent is not null
order by 1,2


-- Countries with highest Infection Rate compared to population

Select location, population, MAX(total_cases) AS HighestInfection, MAX(total_cases/population)*100 AS InfectedPercentage
From Portfolio_Project1..covid_death
Where continent is not null
Group by location, population
order by InfectedPercentage desc

-- Countries with highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) AS Death_Count
From Portfolio_Project1..covid_death
Where continent is not null
Group by location
order by Death_Count desc

-- By Continent

Select location, MAX(cast(total_deaths as int)) AS Death_Count
From Portfolio_Project1..covid_death
Where continent is null
Group by location
order by Death_Count desc

-- joining Tables

Select *
From Portfolio_Project1..covid_death d
Join Portfolio_Project1..covid_vaccination v
	On d.location = v.location
	and d.date = v.date

-- Partition of vaccinations

Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(Cast(v.new_vaccinations as bigint)) OVER (Partition BY d.location ORDER BY d.location,d.date) 
as EvolveVaccineCount
From Portfolio_Project1..covid_death d
Join Portfolio_Project1..covid_vaccination v
	On d.location = v.location
	and d.date = v.date
Where d.continent is not null
order by 2,3


-- Total population Vs Vaccination

-- By USE CTE

With PopVsVac (Continent,location, date, population, new_vaccinations, EvolveVaccineCount)
as
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(Cast(v.new_vaccinations as bigint)) OVER (Partition BY d.location ORDER BY d.location,d.date) 
as EvolveVaccineCount
From Portfolio_Project1..covid_death d
Join Portfolio_Project1..covid_vaccination v
	On d.location = v.location
	and d.date = v.date
Where d.continent is not null
)
Select *, (EvolveVaccineCount/population)*100 as NewVaccinePercent
From PopVsVac



-- By Temp Table

Drop table if exists #PeopleVaccinatePercent
Create Table #PeopleVaccinatePercent
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
EvoleVaccineCount numeric
)

Insert into #PeopleVaccinatePercent
Select d.continent, d.location, d.date, d.population,v.new_vaccinations, 
SUM(CAST(new_vaccinations as bigint)) OVER (partition by d.location ORDER BY d.location, d.date) as EvolveVaccineCount
From Portfolio_Project1..covid_death d
JOIN Portfolio_Project1..covid_vaccination v
	On d.location = v.location
	and d.date = v.date
Where d.continent is not null

Select *, (EvoleVaccineCount/population)*100 as NewVaccinePercent
From #PeopleVaccinatePercent



-- Views for visualization

--View1

Create View PeopleVaccinatePercent as
Select d.continent, d.location, d.date, d.population,v.new_vaccinations, 
SUM(CAST(new_vaccinations as bigint)) OVER (partition by d.location ORDER BY d.location, d.date) as EvolveVaccineCount
From Portfolio_Project1..covid_death d
JOIN Portfolio_Project1..covid_vaccination v
	On d.location = v.location
	and d.date = v.date
Where d.continent is not null



