/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


--SELECT *
--FROM PortfolioProject..[Covid-Vaccinations]
--ORDER BY 3,4 


--SELECT *
--FROM PortfolioProject..[Covid-Deaths]
--Order By 3,4 


--SELECT location, date, total_cases_per_million, new_cases, total_deaths, [ population ]
--From  PortfolioProject..[Covid-Deaths]
--order by 1,2 



 --Total Deaths vs Total Cases 
 -- This displays the liklihood of a person dying if they contract COVID in their contry. 

SELECT location, date, total_cases_per_million, new_cases, total_deaths,(total_deaths/total_cases_per_million)*100
From  PortfolioProject..[Covid-Deaths]
Where location like '%african%'
order by 1,2 



-- Total Cases vs Population 

-- Shows what percentage of population got COVID
SELECT location, date, [ population ], total_cases_per_million,([ population ]/total_cases_per_million)*100
From  PortfolioProject..[Covid-Deaths]
Where location like '%african%'
order by 1,2 

-- Looking at Countries with Highest Infection Rate compared to Population 
Select location,  [ population ], MAX (total_cases_per_million) AS HighestInfectionCount, MAX(([ population ]/total_cases_per_million))*100 as PercentPopulationInfected 
From  PortfolioProject..[Covid-Deaths]
--Where location like '%african%'
Group by location,  [ population ]
order by 1,2 

-- Countries with Highest Death Count per Population
Select location, MAX (total_deaths) AS TotalDeathCount
From PortfolioProject..[Covid-Deaths]
Where continent is not null
Group by location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population
Select continent, MAX (total_deaths) AS TotalDeathCount
From PortfolioProject..[Covid-Deaths]
Where continent is not null
Group by location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases_per_millions, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%african%'
where continent is not null 
--Group By date
order by 1,2

-- Looking at Total Population vs Vaccinations 
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.[population], vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/[population])*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, [population], New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.[population], vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/[population])*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/[population])*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
[Population] numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.[population], vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/[population])*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.[population], vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
