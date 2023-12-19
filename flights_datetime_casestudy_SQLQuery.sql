SELECT * FROM campusx.flights;
use campusx;

-- 	1. Find the month with most number of flights

SELECT MONTHNAME(date_of_journey),COUNT(*) FROM flights
GROUP BY MONTHNAME(date_of_journey) ORDER BY COUNT(*) DESC LIMIT 1;

-- 	2. Which week day has most costly flights

SELECT DAYNAME(date_of_journey),AVG(price) FROM flights
GROUP BY DAYNAME(date_of_journey)
ORDER BY AVG(price) DESC LIMIT 1;

-- 3. Find number of indigo flights every month

SELECT MONTHNAME(date_of_journey) AS Month_Name, COUNT(*) AS Count FROM flights WHERE airline = 'Indigo'
GROUP BY MONTHNAME(date_of_journey), MONTH(date_of_journey)
ORDER BY MONTH(date_of_journey) ASC;

-- 	4. Find list of all flights that depart between 10AM and 2PM from Delhi to Banglore

SELECT * FROM flights
WHERE source = 'Banglore' AND destination = 'Delhi' 
AND dep_time > '10:00:00' AND dep_time < '14:00:00';

-- 5. Find the number of flights departing on weekends from Bangalore

SELECT COUNT(*) FROM flights
WHERE source = 'banglore' AND DAYNAME(date_of_journey) IN ('saturday','sunday');

-- 6. Calculate the arrival time for all flights by adding the duration to the departure time.

ALTER TABLE flights ADD COLUMN departure DATETIME;

UPDATE flights
SET departure = STR_TO_DATE(CONCAT(date_of_journey,' ',dep_time),'%Y-%m-%d %H:%i');

ALTER TABLE flights
ADD COLUMN duration_mins INTEGER,
ADD COLUMN arrival DATETIME;

SELECT Duration,
REPLACE(SUBSTRING_INDEX(duration,' ',1),'h','')*60 + 
CASE
	WHEN SUBSTRING_INDEX(duration,' ',-1) = SUBSTRING_INDEX(duration,' ',1) THEN 0
    ELSE REPLACE(SUBSTRING_INDEX(duration,' ',-1),'m','')
END AS 'mins'
FROM flights;

UPDATE flights
SET duration_mins = 
  CASE
    -- Case when duration contains both hours and minutes ('Xh Xm')
    WHEN duration LIKE '%h%' AND duration LIKE '%m%' THEN
      REPLACE(SUBSTRING_INDEX(duration,' ',1),'h','') * 60 + REPLACE(SUBSTRING_INDEX(duration,' ',-1),'m','')
      
    -- Case when duration contains only hours ('Xh')
    WHEN duration LIKE '%h%' THEN
      REPLACE(SUBSTRING_INDEX(duration,' ',1),'h','') * 60
      
    -- Case when duration contains only minutes ('Xm')
    WHEN duration LIKE '%m%' THEN
      REPLACE(duration, 'm', '')
  END;

UPDATE flights
SET arrival = DATE_ADD(departure,INTERVAL duration_mins MINUTE);

SELECT TIME(arrival) FROM flights;

-- 	7. Calculate the arrival date for all the flights

SELECT DATE(arrival) FROM flights;

-- 8. Find the number of flights which travel on multiple dates.

SELECT COUNT(*) FROM flights WHERE DATE(departure) != DATE(arrival);

-- 9. Calculate the average duration of flights between all city pairs. The answer should In xh ym format

SELECT source,destination,
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration' FROM flights
GROUP BY source,destination;

-- 10. Find all flights which departed before midnight but arrived at their destination after midnight having only 0 stops.

SELECT * FROM flights WHERE total_stops = 'non-stop' AND DATE(departure) < DATE(arrival);

-- 11. Find quarter wise number of flights for each airline

SELECT airline,QUARTER(departure),COUNT(*)
FROM flights GROUP BY airline,QUARTER(departure);

-- 13. Average time duration for flights that have 1 stop vs more than 1 stops

WITH temp_table AS (SELECT *,
CASE 
	WHEN total_stops = 'non-stop' THEN 'non-stop'
    ELSE 'with stop'
END AS 'temp'
FROM flights)
SELECT temp,
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration',
AVG(price) AS 'avg_price'
FROM temp_table
GROUP BY temp;

-- 	14. Find all Air India flights in a given date range originating from Delhi
-- 1st Mar 2019 to 10th Mar 2019 

SELECT * FROM flights
WHERE source = 'Delhi' AND DATE(departure) BETWEEN '2019-03-01' AND '2019-03-10';

-- 15. Find the longest flight of each airline

SELECT airline,
TIME_FORMAT(SEC_TO_TIME(MAX(duration_mins)*60),'%kh %im') AS 'max_duration'
FROM flights GROUP BY airline
ORDER BY MAX(duration_mins) DESC;

-- 16. Find all the pair of cities having average time duration > 3 hours

SELECT source,destination,
TIME_FORMAT(SEC_TO_TIME(AVG(duration_mins)*60),'%kh %im') AS 'avg_duration' FROM flights
GROUP BY source,destination HAVING AVG(duration_mins) > 180;

--  17. Make a weekday vs time grid showing frequency of flights from Banglore and Delhi

SELECT DAYNAME(departure),
  SUM(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS '12AM - 6AM',
  SUM(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS '6AM - 12PM',
  SUM(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS '12PM - 6PM',
  SUM(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS '6PM - 12AM',
  DAYOFWEEK(departure) AS day_of_week_num
FROM flights
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure), day_of_week_num
ORDER BY day_of_week_num ASC;


-- 	18. Make a weekday vs time grid showing avg flight price from Banglore and Delhi

SELECT DAYNAME(departure),
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price ELSE NULL END) AS '12AM - 6AM',
AVG(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS '6AM - 12PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS '12PM - 6PM',
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS '6PM - 12PM',
DAYOFWEEK(departure) AS day_of_week_num
FROM flights
WHERE source = 'Banglore' AND destination = 'Delhi'
GROUP BY DAYNAME(departure),day_of_week_num
ORDER BY DAYOFWEEK(departure) ASC;












