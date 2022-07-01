select * 
from portfolio_projects..CovidDeaths$

order by 3,4
----select * 
----from portfolio_projects..CovidVaccinations$
----order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from portfolio_projects..CovidDeaths$
order by 1,2
--death percentage per cases
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolio_projects..CovidDeaths$
where location like '%india%'
order by 1,2
--total cases per population
select location,date,total_cases,population, (total_cases/population)*100 as casepercentage
from portfolio_projects..CovidDeaths$
where location like '%india%'
order by 1,2
--country with higher infection rate
select location,max(total_cases) as highestinfectioncount,population, max((total_cases/population))*100 as casepercentage
from portfolio_projects..CovidDeaths$
group by location,population
order by casepercentage desc
--places effected more
select location,max(total_cases) as highestinfectioncount,population
from portfolio_projects..CovidDeaths$
group by location,population
order by highestinfectioncount desc

--number of person died
select location,max(cast (total_deaths as int) )as highestdeathcount
from portfolio_projects..CovidDeaths$
where continent is  not null
group by location
order by highestdeathcount desc
--break this continent

select location,max(cast (total_deaths as int) )as highestdeathcount
from portfolio_projects..CovidDeaths$
where continent is  null
group by location
order by highestdeathcount desc

--highest death count in continent per population
select continent,max(cast (total_deaths as int) )as highestdeathcount
from portfolio_projects..CovidDeaths$
where continent is not null
group by continent
order by highestdeathcount desc

---global calculations

select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int))as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases) *100 as deathpercentage
from portfolio_projects..CovidDeaths$
where continent is not null
group by date
order by 1,2

--population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,--(cast(dea.population as bigint)) as totalpopulation,sum(cast(new_vaccinations as bigint))as totalvaccinations,sum(cast(new_vaccinations as bigint))/sum(cast(dea.population as bigint))*100 as vaccinationrate
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)
from portfolio_projects..CovidDeaths$ dea
 join portfolio_projects..CovidVaccinations$ vac
 on dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 order by 2,3

 --use cte
 with popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
 as
 (select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,--(cast(dea.population as bigint)) as totalpopulation,sum(cast(new_vaccinations as bigint))as totalvaccinations,sum(cast(new_vaccinations as bigint))/sum(cast(dea.population as bigint))*100 as vaccinationrate
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolio_projects..CovidDeaths$ dea
 join portfolio_projects..CovidVaccinations$ vac
 on dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 --order by 2,3
 )
 select *, (rollingpeoplevaccinated/population)*100 as percentagevaccinated
 from popvsvac

 --temp table
 drop table if exists #percentagevaccinated
 create table #percentagevaccinated
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric
 )


 insert into #percentagevaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,--(cast(dea.population as bigint)) as totalpopulation,sum(cast(new_vaccinations as bigint))as totalvaccinations,sum(cast(new_vaccinations as bigint))/sum(cast(dea.population as bigint))*100 as vaccinationrate
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)
from portfolio_projects..CovidDeaths$ dea
 join portfolio_projects..CovidVaccinations$ vac
 on dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 order by 2,3

select *, (rollingpeoplevaccinated/population)*100 as percentagevaccinated
 from #percentagevaccinated

 --view for later visualization
 create view covid19 as
 select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int))as totaldeaths,sum(cast(new_deaths as int))/sum(new_cases) *100 as deathpercentage
from portfolio_projects..CovidDeaths$
where continent is not null
group by date
--order by 1,2

select *
from covid19
----
CREATE VIEW 
populationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,--(cast(dea.population as bigint)) as totalpopulation,sum(cast(new_vaccinations as bigint))as totalvaccinations,sum(cast(new_vaccinations as bigint))/sum(cast(dea.population as bigint))*100 as vaccinationrate
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
--,(rollingpeoplevaccinated/population)
from portfolio_projects..CovidDeaths$ dea
 join portfolio_projects..CovidVaccinations$ vac
 on dea.location = vac.location 
 and dea.date = vac.date
 where dea.continent is not null
 group by dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
 --order by 2,3

 select *
 from populationvaccinated