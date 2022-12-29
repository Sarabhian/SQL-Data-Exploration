
-- In This project I tried to explore the covid-19 data and get insights on it , data is from 1st jan 2019 to 23 dec 2022

select location, date,total_cases,new_cases,total_deaths,population
from dataAnalysis..CovidDeaths22
order by 1,2

-- getting data of total unique countries 

select  DISTINCT(location) as states
from dataAnalysis..CovidDeaths22
order by location

-- 1. looking at total cases vs total deaths 
-- DeathPrecentage : shows likelyhood of dying due to covid-19 if get's infected 

select date, location,total_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage,
(total_deaths/population)*100 as DeathByPopulation
from dataAnalysis..CovidDeaths22
--where location in ('India','China','United States','Russia')
where continent is not null
order by date  , total_cases desc


-- 2. looking at the Countries with Highest Infection Rate & DeathPercentage by population 
-- PercentPopulationInfected : shows total population infected 
-- DeathPercentByPopulation : total deaths % for given total population 

select location, population,
max(total_cases) as HighestInfectionCount,
max(total_cases/population)*100 as PercentPopulationInfected,
max(total_deaths/population)*100 as DeathPercentByPopulation
from dataAnalysis..CovidDeaths22
where continent is not null --to exclude continent from the data
group by location ,population
order by HighestInfectionCount 

-- 3. Countries with Highest Death Count per Population
select location, population,
max(cast(total_deaths as int)) as TotalDeathCount
from dataAnalysis..CovidDeaths22
where continent is not null --to exclude continent from the data
group by location ,population
order by TotalDeathCount 

-- Continent wise analysis

-- 4. total death count continent wise ( listed location & unlisted location)
-- a. listed continent wise
select continent,
max(cast(total_deaths as int)) as TotalDeathCount,
max(cast(total_cases as int)) as TotalCases
from dataAnalysis..CovidDeaths22
where continent is not null --to exclude continent from the data
group by continent
order by TotalDeathCount desc 
-- counts only those locations where continent is not null , 
-- but in data there are certain locations where continent is null but there exist a state or islands or some other things.

-- b. unlisted continent
select location,
max(cast(total_deaths as int)) as TotalDeathCount,
max(cast(total_cases as int)) as TotalCases
from dataAnalysis..CovidDeaths22
where continent is null and  location not in ('High income','Low income','Lower middle income','Upper middle income')
group by location
order by 2 desc

-- Global Numbers
-- 5. total deaths and total cases till date
-- total cases on each day globally
select 
date,
SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeaths
from dataAnalysis..CovidDeaths22
--where location in ('India','China','United States','Russia')
where continent is not null
group by date
order by date

--6 total cases, deaths till date 
select 
SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeaths
from dataAnalysis..CovidDeaths22
--where location in ('India','China','United States','Russia')
where continent is not null


-- vaccination analysis 

-- 7 Looking at total population and total vaccinations 
select d.continent ,d.location, d.date, d.population,
v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from  DataAnalysis..CovidDeaths22 d
join DataAnalysis..CovidVaccinations v on
d.location = v.location and d.date = v.date
where d.continent is not null 
order by 5

-- 8 use CTE 
with popvsVac(continent,location,date,population,new_vaccination, rollingPeopleVaccinated)
as (
select d.continent ,d.location, d.date, d.population,
v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from  DataAnalysis..CovidDeaths22 d
join DataAnalysis..CovidVaccinations v on
d.location = v.location and d.date = v.date
where d.continent is not null 

)

select * , (rollingPeopleVaccinated/population)*100
from popvsVac
order by 6 desc


-- create temp table 

drop table if exists #percentPopulationVaccinated
create table  #percentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #percentPopulationVaccinated
select d.continent ,d.location, d.date, d.population,
v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from  DataAnalysis..CovidDeaths22 d
join DataAnalysis..CovidVaccinations v on
d.location = v.location and d.date = v.date
where d.continent is not null 

select * , (rollingPeopleVaccinated/population)*100 as percentrollingvaccinatedpop
from #percentPopulationVaccinated
order by 6 desc

drop view if exists q1, q2,q3,q4_1,q4_2,q5,q6,q7,q8
create view  q1 as
select date, location,total_cases,total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage,
(total_deaths/population)*100 as DeathByPopulation
from dataAnalysis..CovidDeaths22
--where location in ('India','China','United States','Russia')
where continent is not null
--order by date desc , total_cases desc

create view q2 as
select location, population,
max(total_cases) as HighestInfectionCount,
max(total_cases/population)*100 as PercentPopulationInfected,
max(total_deaths/population)*100 as DeathPercentByPopulation
from dataAnalysis..CovidDeaths22
where continent is not null --to exclude continent from the data
group by location ,population
--order by HighestInfectionCount desc

create view q3 as 
select location, population,
max(cast(total_deaths as int)) as TotalDeathCount
from dataAnalysis..CovidDeaths22
where continent is not null --to exclude continent from the data
group by location ,population
--order by TotalDeathCount desc


create view  q4_1 as
select continent,
max(cast(total_deaths as int)) as TotalDeathCount,
max(cast(total_cases as int)) as TotalCases
from dataAnalysis..CovidDeaths22
where continent is not null --to exclude continent from the data
group by continent
--order by TotalDeathCount desc 

create view  q4_2 as
select location,
max(cast(total_deaths as int)) as TotalDeathCount,
max(cast(total_cases as int)) as TotalCases
from dataAnalysis..CovidDeaths22
where continent is null and  location not in ('High income','Low income','Lower middle income','Upper middle income')
group by location
--order by 2 desc

create view  q5 as
select 
date,
SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeaths
from dataAnalysis..CovidDeaths22
--where location in ('India','China','United States','Russia')
where continent is not null
group by date
--order by date

create view  q6 as
select 
SUM(new_cases) as TotalCases,
SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentDeaths
from dataAnalysis..CovidDeaths22
--where location in ('India','China','United States','Russia')
where continent is not null

create view  q7 as
select d.continent ,d.location, d.date, d.population,
v.new_vaccinations,
sum(CONVERT(int,v.new_vaccinations)) over (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from  DataAnalysis..CovidDeaths22 d
join DataAnalysis..CovidVaccinations v on
d.location = v.location and d.date = v.date
where d.continent is not null 
--order by 5 desc

select * from q1 
select * from q2
select * from q3
select * from q4_1
select * from q4_2
select * from q5
select * from q6
select * from q7

