-- 1. what are the 3 elevators with the most breakdowns?
SELECT name, COUNT(breakdowns.id)  as total_breakdowns
	FROM elevators
    	JOIN breakdowns ON elevators.id = breakdowns.elevator_id
GROUP BY name
ORDER BY 2 DESC
LIMIT 3;
-- Please note there are other elevators with total breakdowns = 5 (for rank 2 & 3)
SELECT count(elevator_id) 
	FROM (SELECT elevator_id, COUNT(*) 
          	FROM breakdowns
		GROUP BY elevator_id
		HAVING COUNT(*) = 5) AS break;
-- So top 3 can be different, here the list of other possibilities for rank 2 and 3
SELECT elevator_id, name
	FROM (SELECT elevator_id, COUNT(*) 
          	FROM breakdowns
		GROUP BY elevator_id
		HAVING COUNT(*) = 5) AS break
      JOIN elevators ON break.elevator_id = elevators.id;


-- 2. for each elevator, when was the last visit done?
WITH last_visit AS(SELECT DISTINCT elevator_id, MAX(due_date) as last_visit_done
	FROM visits
WHERE status = 'DONE'
GROUP BY elevator_id
LIMIT 5)
SELECT name, elevator_id, last_visit_done
	FROM elevators
    	JOIN last_visit ON elevators.id = last_visit.elevator_id;
		

-- 3. what is the elevator with the most "relapses"?
--    a "relapse" is a breakdown occuring on an elevator
--    that is 90 days away from the previous one at most

WITH dates AS(SELECT elevator_id, start_date, end_date, 
	LAG(start_date, 1) OVER (partition by elevator_id order by end_date DESC) AS lag
	FROM breakdowns
ORDER BY elevator_id, end_date DESC),

relapses AS(SELECT id, name, end_date, lag, 
			CASE 
           	WHEN (lag - end_date) < 90 THEN 1
            ELSE 0
			END relapse
      			FROM elevators
      				JOIN dates ON elevators.id = dates.elevator_id)
SELECT name, SUM(relapse) 
	FROM relapses
GROUP BY name
ORDER BY 2 DESC
LIMIT 1
;
