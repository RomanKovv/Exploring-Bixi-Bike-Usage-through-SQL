/*
Bixi Project - Part 1 - Data Analysis in SQL

Author: Roman Kovalchuk

2023-01-27



*/

-- initiate bixi database
USE bixi;

-- Counting the entries in the database
SELECT 
  COUNT(*) 
FROM 
  stations;

SELECT 
  COUNT(*) 
FROM 
  trips;

-- view Stations Data
SELECT 
  * 
FROM 
  stations;

-- view Trips Data
SELECT 
  * 
FROM 
  trips;

/* Question 1: First, we will attempt to gain an overall view of the volume of usage of Bixi Bikes 
and what factors influence it. Using the correct SQL queries, calculate and interpret the following: */

-- 1.  The total number of trips for the year of 2016.
SELECT 
  COUNT(*) 
FROM 
  trips 
WHERE 
  YEAR(start_date) = "2016" 
  AND YEAR(end_date) = "2016";
-- The total amount of trips for 2016 is 3,917,401

-- 2. The total number of trips for the year of 2017
SELECT 
  COUNT(*) 
FROM 
  trips 
WHERE 
  YEAR(start_date) = "2017" 
  AND YEAR(end_date) = "2017";
-- The total amount of trips for the year 2017 is 4,666,765

-- 3. The total number of trips for the year of 2016 broken down by month.
SELECT 
  MONTH(end_date), 
  COUNT(*) COUNT 
FROM 
  trips 
WHERE 
  YEAR(start_date) = "2016" 
  AND YEAR(end_date) = "2016" 
GROUP BY 
  MONTH(end_date);

-- 4. The total number of trips for the year of 2017 broken down by month.
SELECT 
  MONTH(end_date), 
  COUNT(*) COUNT 
FROM 
  trips 
WHERE 
  YEAR(start_date) = "2017" 
  AND YEAR(end_date) = "2017" 
GROUP BY 
  MONTH(end_date);

-- 5. The average number of trips a day for each year-month combination in the dataset.
SELECT 
  YEAR(start_date) AS Year, 
  MONTH(start_date) AS Month, 
  COUNT(*) / (
    COUNT(
      DISTINCT DAY(start_date)
    )
  ) AS averageTripsPerDay -- calculating average trips per day for each year-month
FROM 
  trips 
GROUP BY 
  Year, 
  Month 
ORDER BY 
  Year, 
  Month;

-- 6. Save your query results from the previous question (Q 1.5) by creating a table called working_table1
DROP TABLE IF EXISTS working_table1; -- dropping table if it already exists
CREATE TABLE working_table1 (
  month INT, 
  Y2016 float(6, 1), 
  Y2017 float(6, 1)
);
 -- creating a table with Y2016 and Y2017 representing years 2016 and 2017 respectively
INSERT INTO working_table1 (month, Y2016, Y2017) 
VALUES 
  (4, 11870.2, 12228.9), 
  (5, 18099.3, 18949.9), 
  (6, 21050.1, 24727.8), 
  (7, 22556.4, 27765.5), 
  (8, 21702.5, 27094.8), 
  (9, 20675.4, 24395.0), 
  (10, 12660.6, 18048.6), 
  (11, 10008.6, 9986.2);


SELECT * FROM working_table1; -- shows a table with each year value corresponding to the month rounded to 1



/* Question 2: Unsurprisingly, the number of trips varies greatly throughout the year. How about membership status? 
Should we expect members and non-members to behave differently? To start investigating that, calculate:*/

-- 1. The total number of trips in the year 2017 broken down by membership status (member/non-member).*/

SELECT 
  COUNT(*) 
FROM 
  trips 
WHERE 
  YEAR(end_date) = "2017" 
  AND is_member = 0;
-- The total number of trips for non members in 2017 is 882,083

SELECT 
  COUNT(*) 
FROM 
  trips 
WHERE 
  YEAR(end_date) = "2017" 
  AND is_member = 1;
-- The total number of trips for non members in 2017 is 3,784,682


-- 2. The percentage of total trips by members for the year 2017 broken down by month.

-- figuring out total trips in 2017 by members
SELECT 
  COUNT(*) 
FROM 
  trips 
WHERE 
  YEAR(start_date) = "2017" 
  AND is_member = 1;

-- The total trips by members in 2017 is 3,784,682


-- dividing trips by month by total trips by members to get the percentage of trips each month
SELECT 
  MONTH(start_date) AS startDate, 
  COUNT(*) AS numTrips, 
  ROUND(
    COUNT(*) * 100.0 / 3784682, -- dividing the trips per month by total trips to get the percentage of trips for each month
    1
  ) AS Percent 
FROM 
  trips 
WHERE 
  YEAR(start_date) = 2017 
  AND is_member = 1 
GROUP BY 
  MONTH(start_date), 
  is_member 
ORDER BY 
  MONTH(start_date), 
  is_member;
        


/* Question 4: It is clear now that time of year and membership status are intertwined and influence greatly how people use Bixi bikes. 
Next, let's investigate how people use individual stations, and explore station popularity. */

-- 1. What are the names of the 5 most popular starting stations? Determine the answer without using a subquery.

SELECT 
  stations.name, 
  COUNT(*) as numTrips 
FROM 
  trips 
  INNER JOIN stations ON trips.start_station_code = stations.code -- joining trips to stations to get the name of the station
GROUP BY 
  stations.name 
ORDER BY 
  numTrips DESC -- ordering by descending results to show the highest values
LIMIT 
  5; -- showing only 5 values

-- 2. Solve the same question as Q4.1, but now use a subquery. The subquery takes a longer time to compute as it uses more computing power.
SELECT 
  stations.name, 
  COUNT(*) as numTrips 
FROM 
  (
    SELECT 
      COUNT(*) 
    FROM 
      trips 
      INNER JOIN stations ON trips.start_station_code = stations.code 
    GROUP BY 
      stations.name
  ) AS start_station_code 
  JOIN stations 
GROUP BY 
  stations.name 
ORDER BY 
  numTrips DESC 
LIMIT 
  5;



/* Question 5:If we break up the hours of the day as follows:

SELECT CASE
       WHEN HOUR(start_date) BETWEEN 7 AND 11 THEN "morning"
       WHEN HOUR(start_date) BETWEEN 12 AND 16 THEN "afternoon"
       WHEN HOUR(start_date) BETWEEN 17 AND 21 THEN "evening"
       ELSE "night"
END AS "time_of_day", */

-- 1. How is the number of starts and ends distributed for the station Mackay / de Maisonneuve throughout the day?


-- determine code for Mackay / de Maisonneuve station
SELECT 
  name, 
  stations.code 
FROM 
  trips 
  JOIN stations ON trips.start_station_code = stations.code 
WHERE 
  name = "Mackay / de Maisonneuve";
-- The code is 6100


-- Finding amount of trips that started at Mackay
SELECT 
  COUNT(DISTINCT id) AS amountOfTrips, 
  CASE WHEN HOUR(start_date) BETWEEN 7 -- case which determines when each trip was started
  AND 11 THEN "morning" WHEN HOUR(start_date) BETWEEN 12 
  AND 16 THEN "afternoon" WHEN HOUR(start_date) BETWEEN 17 
  AND 21 THEN "evening" ELSE "night" END AS "time_of_day" 
FROM 
  trips 
WHERE 
  start_station_code = 6100 
GROUP BY 
  time_of_day;

-- Finding amount of trips that ended at Mackay
SELECT 
  COUNT(DISTINCT id) AS amountOfTrips, 
  CASE WHEN HOUR(start_date) BETWEEN 7  
  AND 11 THEN "morning" WHEN HOUR(start_date) BETWEEN 12 
  AND 16 THEN "afternoon" WHEN HOUR(start_date) BETWEEN 17 
  AND 21 THEN "evening" ELSE "night" END AS "time_of_day" 
FROM 
  trips 
WHERE 
  end_station_code = 6100 
GROUP BY 
  time_of_day;


/* Question 6
List all stations for which at least 10% of trips are round trips. Round trips are those that start and end in the same station. 
This time we will only consider stations with at least 500 starting trips. (Please include answers for all steps outlined here*/

-- First, write a query that counts the number of starting trips per station.

SELECT 
  name, 
  COUNT(*) as numTrips 
FROM 
  trips 
  JOIN stations ON trips.start_station_code = stations.code 
GROUP BY 
  name 
ORDER BY 
  numTrips DESC;

-- Second, write a query that counts the number of round trips for each station.
SELECT 
  name, 
  COUNT(*) as numTrips 
FROM 
  trips 
  JOIN stations ON trips.start_station_code = stations.code 
WHERE 
  start_station_code = end_station_code 
GROUP BY 
  name 
ORDER BY 
  numTrips DESC;

-- Combine the above queries and calculate the fraction of round trips to the total number of starting trips for each station.

SELECT 
  stations.name AS startStation, 
  COUNT(*)/(
    SELECT 
      COUNT(*) 
    FROM 
      trips 
    WHERE 
      start_station_code = end_station_code
  ) AS fractionRoundTrips -- calculating fraction of trips starting from each station
FROM 
  stations 
  JOIN trips ON trips.start_station_code = stations.code 
GROUP BY 
  stations.name 
ORDER BY 
  fractionRoundTrips DESC;

-- Filter down to stations with at least 500 trips originating from them and having at least 10% of their trips as round trips.

SELECT 
  stations.name AS startStation, 
  COUNT(*)/(
    SELECT 
      COUNT(*) 
    FROM 
      trips 
    WHERE 
      start_station_code = end_station_code
  ) AS fractionRoundTrips 
FROM 
  stations 
  JOIN trips ON trips.start_station_code = stations.code 
WHERE 
  start_date >= 500 -- setting start date greater or equal to 500 trips
  AND start_station_code = end_station_code >=.10 -- calculating roundtrips to be greater or equal to 10%
GROUP BY 
  stations.name 
ORDER BY 
  fractionRoundTrips DESC;


