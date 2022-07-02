select *
from portfolio_project2..literacy

select *
from portfolio_project2..state

--number of rows in our dataset

select count(*)
from portfolio_project2..literacy

--data set for kerala and karnataka
select *
from portfolio_project2..state
where State = 'Kerala' or State = 'Karnataka'
order by 2

--kerala total population
select sum(Population) as totalpopulation
from portfolio_project2..state
where State = 'Kerala' 
--order by 2


--kannur total population
select sum(Population) as totalpopulation
from portfolio_project2..state
where District = 'Kannur'

--areakm per population
select *, (Area_km2/Population)*100
from portfolio_project2..state
where State = 'kerala'

--highest population city
select District,State,Area_km2,  Max(population) as highestpopulation,max(Area_km2/Population)
from portfolio_project2..state
where State <> '#N/A'and State = 'kerala'
group by District,State,Area_km2
order by max(population) desc

--country population
select  sum(Population) as highestpopulation,(sum(Area_km2)/sum(Population)) as percentagepop
from portfolio_project2..state
where State <> '#N/A'

--lets break the literacy data set

select District,State, sum(Sex_Ratio) over (partition by State)as lit,
from portfolio_project2..literacy

--group by State 
order by lit 

--join both data set
select st.State,st.District,st.Population,Area_km2,Growth,Sex_Ratio,Literacy
from portfolio_project2..state st
join portfolio_project2..literacy li
on st.District = li.District and
st.State = li.State

--average literacy per state
select st.State,st.District,st.Population,Area_km2,Growth,Sex_Ratio,Literacy,
avg(literacy) over (partition by st.State) as averageliteracy
--, (averageliteracy/Population)
from portfolio_project2..state st
join portfolio_project2..literacy li
on st.District = li.District and
st.State = li.State
where st.State = 'kerala'
order by st.State

-- cte
with avgpop (State,District,Population,Area_km2,Growth,Sex_Ratio,Literacy,averageliteracy)
as(
select st.State,st.District,st.Population,Area_km2,Growth,Sex_Ratio,Literacy,
avg(literacy) over (partition by st.State) as averageliteracy
--, (averageliteracy/Population)
from portfolio_project2..state st
join portfolio_project2..literacy li
on st.District = li.District and
st.State = li.State
where st.State = 'kerala'
--order by st.State
)
select * ,(averageliteracy/Population)* 100 as averagelitperpop
from avgpop 

--creating view
create view averagelit as
select st.State,st.District,st.Population,Area_km2,Growth,Sex_Ratio,Literacy,
avg(literacy) over (partition by st.State) as averageliteracy
--, (averageliteracy/Population)
from portfolio_project2..state st
join portfolio_project2..literacy li
on st.District = li.District and
st.State = li.State
where st.State = 'kerala'
--order by st.State
