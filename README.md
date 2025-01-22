# In-Depth Analysis of IPL Performance Trends (2021-2023)

![IPL Logo](https://github.com/nikkvd/IPL-2024/blob/main/Images/IPL%20Logo.jpg?raw=true)

## Overview
This project focuses on analyzing Indian Premier League (IPL) data from the last three years (2021, 2022, and 2023) to extract actionable insights for cricket fans, analysts, and teams. By using SQL queries to explore player performances, team strategies, and season trends, this analysis forms the basis of a special edition magazine for IPL 2024. The data includes detailed match summaries, player attributes, batting statistics, and bowling statistics, offering a comprehensive view of IPL performance metrics.

## Objective
The primary objective of this project is to leverage historical IPL data to uncover key insights and patterns that enhance fan engagement and assist analysts and teams in understanding performance trends. Specific goals include:

- Identifying top-performing players in batting and bowling based on runs, strike rates, wickets, and economy.

- Highlighting team strategies and success rates, including winning percentages and chasing performance.

- Analyzing season-wise and player-specific trends, such as boundary percentages and dot ball effectiveness.

- Providing accurate, data-driven answers to questions that resonate with the IPL audience.

## Problem Statement
The IPL generates a vast amount of statistical data each season, but extracting meaningful insights from this data requires structured analysis. Fans, analysts, and teams often seek answers to specific questions, such as:

- Who are the most consistent players across multiple seasons?
- What team strategies yield the highest success rates?
- How do individual performances vary under different conditions?

Without a systematic approach, answering such questions and presenting insights in an engaging format is challenging.
This project aims to solve this by using SQL to process raw data and generate concise, insightful results tailored to the interests of IPL stakeholders.

## About the Database

There are 4 datasets (CSV files) for this project:
1. dim_match_summary
2. fact_batting_summary
3. fact_bowling_summary
4. dim_players



Column Description for dim_match_summary:
- team1: Name of the team batting first.
- team2: Name of the team batting second.
- winner: The team that won the match.
- margin: The margin by which the winning team won (runs or wickets).
- matchDate: The date on which the match was played, formatted as MMM DD, YYYY.
- match_id: Unique identifier for each match, prefixed with 'T'.

*******************************************


Column Description for dim_players:
- name: The full name of the player.
- team: The IPL team the player is associated with.
- battingStyle: The batting style of the player (e.g., Right hand Bat, Left hand Bat).
- bowlingStyle: The bowling style of the player (e.g., Right arm Offbreak, Legbreak).
- playingRole: The primary role of the player in the team (e.g., Batter, Bowler, Allrounder).


*******************************************


Column Description for fact_batting_summary:

- match_id: Links to the dim_match_summary for match details, prefixed with 'T'.
- match: Description of the match in "Team1 Vs Team2" format.
- teamInnings: The team that is batting in the specified innings.
- battingPos: The batting order position of the player.
- batsmanName: The name of the batsman.
- out/not_out: Indicates whether the batsman was out or not out.
- runs: The number of runs scored by the batsman.
- balls: The number of balls faced by the batsman.
- 4s: The number of boundaries (4 runs) hit by the batsman.
- 6s: The number of sixes hit by the batsman.
- SR (Strike Rate): The strike rate of the batsman during the innings.


*******************************************



Column Description for fact_bowling_summary:

- match_id: Links to the dim_match_summary for match details, prefixed with 'T'.
- match: Description of the match in "Team1 Vs Team2" format.
- bowlingTeam: The team that is bowling in the specified innings.
- bowlerName: The name of the bowler.
- overs: The number of overs bowled by the player.
- maiden: The number of maiden overs bowled.
- runs: The number of runs conceded by the bowler.
- wickets: The number of wickets taken by the bowler.
- economy: The bowler's economy rate.
- 0s: The number of dot balls bowled.
- 4s: The number of boundaries conceded.
- 6s: The number of sixes conceded.
- wides: The number of wide balls bowled.
- noBalls: The number of no balls bowled.


### ER Diagram
![ER Diagram](https://github.com/nikkvd/IPL-2024/blob/main/Images/ER%20Diagram.png?raw=true)


*******************************************

## Database Creation and Upload Dataset
```sql
create database IPL;
use IPL;
select * from dim_match_summary;
select * from dim_players;
select * from fact_bating_summary;
select * from fact_bowling_summary;
```

## 1. Top 10 batsmen based on past 3 years total runs scored.
```sql
select * from
(select *,dense_rank()over(order by total_runs desc) as rnk from
(select batsmanName,sum(runs) as total_runs
from fact_bating_summary as fb join dim_match_summary as dm
on fb.match_id = dm.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by batsmanName,matchDate
order by total_runs desc)temp)temp2
where rnk<=10;
```

**Objective:** Identify the most consistent and high-scoring batsmen over the last three IPL seasons to showcase their dominance and reliability for fans and analysts.
## 2. Top 10 batsmen based on past 3 years batting average. (min 60 balls faced)
```sql
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
```

**Objective:** Highlight batsmen who maintain consistency with a solid average, ensuring a balance between runs scored and frequency of dismissals, while filtering out outliers with insufficient data.
## 3. Top 10 batsmen based on past 3 years strike rate (min 60 balls faced)
```sql
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
```

**Objective:** Find batsmen who have consistently scored runs at a rapid pace, providing insights into impactful players for situations requiring high run rates.
## 4. Top 10 bowlers based on past 3 years total wickets taken.
```sql
select * from 
(select *,dense_rank()over(order by total_wickets desc) as rnk from
(select bowlerName,sum(wickets) as total_wickets
from fact_bowling_summary as fb join dim_match_summary as dm
on dm.match_id = fb.match_id
where (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by bowlerName)temp)temp2
where rnk<=10;
```

**Objective:** Showcase bowlers who have been the most effective in taking wickets and disrupting batting lineups, helping analysts focus on match-winning bowlers.
## 5. Top 10 bowlers based on past 3 years economy rate. (min 60 balls bowled)
```sql
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
```

**Objective:** Identify bowlers who consistently maintain tight control over runs, emphasizing their ability to limit opposition scoring rates in crucial moments.
## 6. Top 5 batsmen based on past 3 years boundary percentage (fours and sixes).
```sql
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
```

**Objective:** Highlight the most aggressive and entertaining batsmen who rely on boundaries to make a significant impact, appealing to fans who enjoy power-hitting.
## 7. Top 5 bowlers based on past 3 years dot ball percentage.
```sql
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
```

**Objective:** Identify bowlers who excel in building pressure by delivering dot balls, a crucial factor in restricting runs and forcing mistakes from batsmen.
## 8. Top 4 teams based on past 3 years winning percentage.
```sql
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
```

**Objective:** Determine the most successful teams in terms of overall performance, helping fans and analysts gauge team consistency and dominance over recent seasons.
## 9.Top 2 teams with the highest number of wins achieved by chasing targets over the past 3 years.
```sql
select * from
(select *,dense_rank()over(order by cnt desc) as rnk from
(select winner,count(winner) as cnt
from dim_match_summary
where margin like '%wic%' and (2024 - year(str_to_date(matchDate,'%b %d,%Y'))) <=3
group by winner)temp)temp2
where rnk<=2;
```

**Objective:** Identify teams that excel under pressure while chasing targets, offering insights into their resilience and adaptability in different match scenarios.
## 10. Which season had the highest total number of runs scored by a single team?
```sql
select teamInnings,Year,runs from
(select *,dense_rank()over(order by runs desc) as rnk from
(select fb.match_id,teamInnings,year(str_to_date(matchdate,'%b %d,%Y')) as Year,sum(runs) as runs 
from fact_bating_summary fb join dim_match_summary as dm
on dm.match_id = fb.match_id
group by fb.match_id,teamInnings,Year
order by runs desc)temp)temp1
where rnk=1;
```

**Objective:** Highlight the most explosive batting performances by a team in a single season, showcasing record-breaking achievements and entertaining cricket for fans.



*******************************************

- This dataset was obtained from the Codebasics website.
  
  https://codebasics.io/challenge/codebasics-resume-project-challenge
