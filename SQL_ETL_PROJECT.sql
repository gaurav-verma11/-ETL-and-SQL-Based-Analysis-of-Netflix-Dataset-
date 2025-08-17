CREATE DATABASE netflix_db;
select * from netflix_titles
order by title;

#FINDING DUPLICATES
select show_id , count(*)
from netflix_titles
group by show_id
having count(*)>1 ;
#THERE IS  NO DUPLICATES IN SHOW ID

#CHECKING DUPLICATES IN TITLE
select title , count(*)
from netflix_titles
group by title
having count(*)>1 ;
#THERE IS SOME DUPLICATES IN THIS DATA 

#CREATIGN A DUPLICATE TABLE FOR THE DATA CLEANING SO THE RAW DATA IS SAFE 
create table netflix_staging 
like netflix_titles; 

insert netflix_staging
select * from netflix_titles;
select * from netflix_staging;
#created a duplicate table for data cleaning 


#REMOVING DUPLICATES FROM THIS DATA 
SELECT n.*
FROM netflix_staging n
JOIN (
    SELECT UPPER(title) AS title_upper, type
    FROM netflix_staging
    GROUP BY UPPER(title), type
    HAVING COUNT(*) > 1
) dup
ON UPPER(n.title) = dup.title_upper
AND n.type = dup.type
ORDER BY n.title;

with cte as(
select*
,row_number() over(partition by title , type order by show_id) as rn
from netflix_staging
)
select *
from cte
where rn =1 ;
#DELETED ALL THE DUPLICATES FROM THIS DATA 

#NOW WE CAN START THE ANALYSIS FOR THE PROJECT 

-- HERE ARE SOME BUSSINESS PROBLEMS 


-- Compare Movies vs TV Shows count
select type, count(*) as total_movies_shows
from netflix_staging
group by type;


-- WHICH COUNTRIES SHOULD NETFLIX TARGET FOR NEW PARTNERSHIPS?
-- -- Top 10 content-producing countries
SELECT country, COUNT(*) AS total_shows
FROM netflix_staging
WHERE country <> 'Unknown'
GROUP BY country
ORDER BY total_titles DESC
LIMIT 10;

-- NETFLIX RELEASES PER YEAR AND HOW IT GORW EVERY YEAR
select release_year, count(*) as total_releases
from netflix_staging
group by release_year
order by release_year;

-- POPULAR GENRE OF NETFLIX WHICH HAS TO BE MORE FOCUS 
-- Extract the first genre and count
SELECT TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS main_genre,
       COUNT(*) AS total
FROM netflix_staging
GROUP BY main_genre
ORDER BY total DESC
LIMIT 10;

-- TOP DIRECTORS OF NETFLIX WHICH HAS PRODUSED MOST NUMBERS OF TV SHOWS AND MOVIES
SELECT director, COUNT(*) AS total_titles
FROM netflix_staging
WHERE director <> 'Unknown'
GROUP BY director
ORDER BY total_titles DESC
LIMIT 10;
















