Select*
From PortfolioProject..CovidDeaths
order by 3,4

Select*
From PortfolioProject..Covidvacinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows the liklihood  of dying due to covid 2019 virus

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--looking at the total cases vs population
--Shows what % of people got hte covid 2019 virus

Select Location, date, total_cases, population, (total_cases/population)*100 as Infectionpercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

-- looking at countries with highest infection rates vs population

Select Location, population, MAX(total_cases) as Highestinfectioncount, MAX((total_cases/population))*100 as MaxInfectionpercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by MaxInfectionpercentage desc

-- showing the countries with highest death count per population

Select location, Max(cast(Total_deaths as int)) as totaldeathcount
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by totaldeathcount desc


Select Location, population, MAX(total_deaths) as Highestdeathcount, MAX((total_deaths/population))*100 as Maxdeathpercentage
From PortfolioProject..CovidDeaths
Group by location, population
order by Maxdeathpercentage desc

--let's break things down by continent
--total Deaths as per respective country


Select location, Max(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Showing the continent with the highest death count

Select continent, Max(cast(Total_deaths as int))as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--breaking global numbers

Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

-- Global Numbers for death and new cases


Select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2

--joining both covid death and vacination tables
-- looking at total population vs vacinations

select*
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date

--looking at total population vaccinated at a particular timelike per day.


select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2, 3

-- Looking at total population vs vaccinations
-- using partition function to get rolling numbers of the new vactionations.



select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 3,4


-- total people vacinated vs total population of the country. 
--( as newly created coloumn rollingpeoplevacinated cannot be used so to use we have create a CTE or tremp table)
--xxxxxxxxxxxx

select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacinated
--(rollingpeoplevacinated/ population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 3,4

-- total people vacinated vs total population of the country. 
--Creating CTE to make column useable.

with Popvsvac (continent, location, date , population, new_vaccinations, rollingpeoplevacinated)
as
(
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacinated
--(rollingpeoplevacinated/ population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 3,4
)

select*, (rollingpeoplevacinated/ population)*100 as totalvacinatedpercentage
from Popvsvac


-- doing calculation for the same using a temp table
-- Temp Table


Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vacccinations numeric,
rollingpeoplevacinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacinated
--(rollingpeoplevacinated/ population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 3,4

select*, (rollingpeoplevacinated/ population)*100 as totalvacinatedpercentage
from #PercentPopulationVaccinated





-- creating view to store data for later visulizations

Create View Popvsvac as

with Popvsvac (continent, location, date , population, new_vaccinations, rollingpeoplevacinated)
as
(
select dea.date, dea.continent, dea.location, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevacinated
--(rollingpeoplevacinated/ population)*100
From PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvacinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 3,4
)

select*, (rollingpeoplevacinated/ population)*100 as totalvacinatedpercentage
from Popvsvac







