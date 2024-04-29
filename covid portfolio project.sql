select *
from portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from portfolioproject..Covidvaccinations
--order by 3,4


---Select data we are goig to be using 

select location,date,total_cases,new_cases,total_deaths,population
from portfolioproject..CovidDeaths
order by 1,2



---Lokking at total cases v/s total deaths
---shows percentage of dying in your Country 

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where location like '%states%'
order by 1,2


---looking at total cases v/s population
---shows percentage of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as population_infected
from portfolioproject..CovidDeaths
---where location like '%india%'
order by 1,2


---looking at countries with highest infection rate compared to population 

select location,population,max(total_cases) as highestinfection_rate, max((total_cases/population))*100 as population_infected
from portfolioproject..CovidDeaths
---where location like '%india%'
group by location, population
order by population_infected desc 


---showing Countries with highest death count per populaton

select location, max(cast( total_deaths as int)) as totaldeath_count
from portfolioproject..CovidDeaths
---where location like '%india%'
where continent is not null
group by location
order by totaldeath_count desc 


---Break the things by continent

select continent, max(cast( total_deaths as int)) as totaldeath_count
from portfolioproject..CovidDeaths
---where location like '%india%'
where continent is  not null  
group by continent
order by totaldeath_count desc 


---Showing continent with highest death count per population

select continent, max(cast( total_deaths as int)) as totaldeath_count
from portfolioproject..CovidDeaths
---where location like '%india%'
where continent is  not null  
group by continent
order by totaldeath_count desc 



--- Global numbers

select sum(new_cases)  as total_cases ,sum(cast(new_deaths as int)) as total_deaths ,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
--where location like '%states%'
where continent is not null
--group by date
order by 1,2



---Total population v/s Vaccinations

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
   sum(cast(cv.new_vaccinations as int)) over (partition by cd.location  order by cd.location, cd.date) as rollingpeople_vaccinated
--- (rollingpeople_vaccinated/population)*100
from portfolioproject..CovidDeaths cd
join portfolioproject..Covidvaccinations cv 
     on cd.location=cv.location
	 and cd.date=cv.date
where cd.continent is not null
order by 2,3


---use CTE

with popvsvac (continent,location,date, population,rollingpeople_vaccinated,new_vaccinations)  as
(
 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
   sum(cast(cv.new_vaccinations as int)) over (partition by cd.location  order by cd.location, cd.date) as rollingpeople_vaccinated
--- (rollingpeople_vaccinated/population)*100
from portfolioproject..CovidDeaths cd
join portfolioproject..Covidvaccinations cv 
     on cd.location=cv.location
	 and cd.date=cv.date
where cd.continent is not null
)
select *,
(rollingpeople_vaccinated/population)*100  
from popvsvac



---TEMP TABLE    

drop table if exists #percentagepopulationvaccinated
create table #percentagepopulationvaccinated
(
continent nvarchar(220),
location nvarchar(220),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeople_vaccinated numeric
)
insert into #percentagepopulationvaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
   sum(cast(cv.new_vaccinations as int)) over (partition by cd.location  order by cd.location, cd.date) as rollingpeople_vaccinated
--- (rollingpeople_vaccinated/population)*100
from portfolioproject..CovidDeaths cd
join portfolioproject..Covidvaccinations cv 
     on cd.location=cv.location
	 and cd.date=cv.date
where cd.continent is not null

select *,
(rollingpeople_vaccinated/population)*100  
from #percentagepopulationvaccinated


--- Creating view to store data for later visualizations

create view percentagepopulationvaccinated as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
   sum(cast(cv.new_vaccinations as int)) over (partition by cd.location  order by cd.location, cd.date) as rollingpeople_vaccinated
--- (rollingpeople_vaccinated/population)*100
from portfolioproject..CovidDeaths cd
join portfolioproject..Covidvaccinations cv 
     on cd.location=cv.location
	 and cd.date=cv.date
where cd.continent is not null
