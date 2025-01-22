drop database if exists IPL;
create database IPL;
use IPL;
select * from dim_match_summary;
select * from dim_players;
select * from fact_bating_summary;
select * from fact_bowling_summary;

-- 1. Top 10 batsmen based on past 3 years total runs scored.
select * from
(select *,dense_rank()over(order by total_runs desc) as rnk from
(select batsmanName,sum(runs) as total_runs
from fact_bating_summary as fb join dim_match_summary as dm
on fb.match_id = dm.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by batsmanName,matchDate
order by total_runs desc)temp)temp2
where rnk<=10;

-- 2. Top 10 batsmen based on past 3 years batting average. (min 60 balls faced in each season)
with total as
(select batsmanName,avg(runs) as average
from fact_bating_summary as fb join dim_match_summary as dm
on dm.match_id = fb.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by batsmanName),

balls as 
(select batsmanName,year(str_to_date(matchDate,'%b %d,%Y')) as Year,sum(balls) as balls
from fact_bating_summary as fb join dim_match_summary as dm
on dm.match_id = fb.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by batsmanName,Year
having balls >=60)

select * from
(select *,dense_rank()over(order by average desc) as rnk from
(select distinct b.batsmanName,average
from balls as b join total as t
on b.batsmanName = t.batsmanName)temp)temp2
where rnk<=10;

-- 3. Top 10 batsmen based on past 3 years strike rate (min 60 balls faced in each season)
with total as 
(select batsmanName,round(avg(SR),3) as avg_SR
from fact_bating_summary as fb join dim_match_summary as dm
on dm.match_id = fb.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by batsmanName),

balls as 
(select batsmanName,year(str_to_date(matchDate,'%b %d,%Y')) as Year,sum(balls) as balls
from fact_bating_summary as fb join dim_match_summary as dm
on dm.match_id = fb.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by batsmanName,Year
having balls >=60)

select * from
(select *,dense_rank()over(order by avg_SR desc) as rnk from
(select distinct b.batsmanName,avg_SR
from balls as b join total as t
on b.batsmanName = t.batsmanName)temp)temp2
where rnk<=10;


-- 4. Top 10 bowlers based on past 3 years total wickets taken.
select * from 
(select *,dense_rank()over(order by total_wickets desc) as rnk from
(select bowlerName,sum(wickets) as total_wickets
from fact_bowling_summary as fb join dim_match_summary as dm
on dm.match_id = fb.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by bowlerName)temp)temp2
where rnk<=10;


-- 5. Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled ineach season)
with total as 
(select bowlerName,round(avg(economy),3) as avg_eco
from fact_bowling_summary as fb join dim_match_summary as dm
on dm.match_id = fb.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by bowlerName),

balls as 
(select bowlerName,year(str_to_date(matchDate,'%b %d,%Y')) as Year,sum(case when overs like '%.%' then substring_index(overs,'.',1)*6 + substring_index(overs,'.',-1) else overs*6 end) as balls
from fact_bowling_summary as fb join dim_match_summary as dm
on dm.match_id = fb.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by bowlerName,Year
having balls >=60)

select * from
(select *,dense_rank()over(order by avg_eco desc) as rnk from
(select distinct b.bowlerName,avg_eco,balls
from balls as b join total as t
on b.bowlerName = t.bowlerName)temp)temp2
where rnk<=10;
-- 6. Top 5 batsmen based on past 3 years boundary % (fours and sixes).
with players as
(select batsmanName,sum(4s + 6s) as boundary
from fact_bating_summary as fb join dim_match_summary as dm
on fb.match_id = dm.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by batsmanName),

total as
(select sum(4s + 6s) as total
from fact_bating_summary as fb join dim_match_summary as dm
on fb.match_id = dm.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3)

select * from
(select *,dense_rank()over(order by percent desc) as rnk from
(select batsmanName,(boundary/total)*100 as percent
from players as p join total as t
order by percent desc)temp)temp1
where rnk<=5;

-- 7. Top 5 bowlers based on past 3 years dot ball %.
with players as
(select bowlerName,sum(0s) as dots
from fact_bowling_summary as fb join dim_match_summary as dm
on fb.match_id = dm.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by bowlerName),

total as
(select sum(0s) as total
from fact_bowling_summary as fb join dim_match_summary as dm
on fb.match_id = dm.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3)

select * from
(select bowlerName,percent,dense_rank()over(order by percent desc) as rnk from
(select bowlerName,dots,total,(dots/total)*100 as percent
from players as p join total as t)temp)temp1
where rnk<=5;

-- 8. Top 4 teams based on past 3 years winning %.
with team_wise as
(select winner,count(winner) as cnt 
from dim_match_summary 
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by winner),

total as
(select count(winner) as total
from dim_match_summary
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3)

select * from
(select winner,percent,dense_rank()over(order by percent desc) as rnk from
(select winner,cnt,total,(cnt/total)*100 as percent
from team_wise as tw join total as t)temp1)temp2
where rnk<=4;

-- 9.Top 2 teams with the highest number of wins achieved by chasing targets over the past 3 years.
select * from
(select *,dense_rank()over(order by cnt desc) as rnk from
(select winner,count(winner) as cnt
from dim_match_summary
where margin like '%wic%' and (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by winner)temp)temp2
where rnk<=2;


-- 10. Which season had the highest total number of runs scored by a single team?
select teamInnings,Year,runs from
(select *,dense_rank()over(order by runs desc) as rnk from
(select fb.match_id,teamInnings,year(str_to_date(matchdate,'%b %d,%Y')) as Year,sum(runs) as runs 
from fact_bating_summary fb join dim_match_summary as dm
on dm.match_id = fb.match_id
group by fb.match_id,teamInnings,Year
order by runs desc)temp)temp1
where rnk=1;