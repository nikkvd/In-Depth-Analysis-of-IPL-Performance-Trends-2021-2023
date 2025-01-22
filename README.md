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
