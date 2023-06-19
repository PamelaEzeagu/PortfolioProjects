--Selecting data to be used
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
order by 1,2

--Looking at datatypes
EXEC sp_help 'CovidDeaths';

--Changing datatypes
ALTER TABLE CovidDeaths
ALTER COLUMN total_cases float;

ALTER TABLE CovidDeaths
ALTER COLUMN total_deaths float;


--Looking at the percentage of total deaths to total cases in Nigeria(where i'm from) and the united kingdom(where I live) showing the chances of dying from covid in these countries.
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
where location  IN ('Nigeria' , 'United Kingdom')
order by 1,2 DESC


--Looking at the percentage of total cases to population showing percentage of population contracted Covid19
SELECT location,date,total_cases,population, (total_cases/population)*100 as PercentagePopulationInfected
FROM CovidDeaths
--where location  IN ('Nigeria' , 'United Kingdom')
order by 1,2 DESC

--Looking at countries with highest infection rates compared population
SELECT location,MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM CovidDeaths
group by location,population
order by PercentagePopulationInfected DESC

--Looking at countries with highest death count per population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
where continent is not null
group by location
order by 2 DESC

--Now looking at continents
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM CovidDeaths
where continent is not null
group by continent
order by  TotalDeathCount DESC


--Looking at global numbers
SELECT SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM CovidDeaths
where continent is not null
order by 1,2 DESC


--Looking at global numbers by date
SELECT date,SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 as DeathPercentage
FROM CovidDeaths
where continent is not null
Group by date
order by 1,2 DESC


--Joining the CovidDeath table to the CovidVaccinations table
SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date


--Looking at total population to vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
     ON dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Changing datatypes
ALTER TABLE CovidVaccinations
ALTER COLUMN new_vaccinations float;

--Looking at the RollingCount of new vaccinations in each location 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
       ,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3;


--Using a CTE to calculate for the precentage of peopleVaccinated by population

With PopvsVac (continent,location,date,population,new_vaccinations,RollingCountPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
       ,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3;
)

SELECT*,(RollingCountPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
FROM PopVsVac

-

--Creating a TEMP Table

Drop table if exists 
Create Table #PercentagePeopleVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)



insert into #PercentagePeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
       ,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3;

SELECT*,(RollingCountPeopleVaccinated/population)*100 as PercentagePeopleVaccinated
FROM PopVsVac



--Creating view to store data

Create view  PercentagePeopleVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
       ,SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingCountPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac 
ON dea.location = vac.location 
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1,2,3;

--Looking at African countries with the highest percentage of people vaccinated from the above view created
SELECT Continent,Location, MAX(RollingCountPeopleVaccinated)
FROM PercentagePeopleVaccinated
Where Continent = 'Africa'
Group by continent,location
Order by 3 DESC
