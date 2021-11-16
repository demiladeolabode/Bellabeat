------------------------------------------------Bellabeat Case study--------------------------------


SELECT NAME
FROM syscolumns
WHERE id=OBJECT_ID('activity')
ORDER BY NAME asc

SELECT NAME
FROM syscolumns
WHERE id=OBJECT_ID('calories')

SELECT NAME
FROM syscolumns
WHERE id=OBJECT_ID('intensity')

SELECT NAME
FROM syscolumns
WHERE id=OBJECT_ID('steps')



-- every field in intensity, calories, steps is contained in activity
-- left with 2 tables to work on (activity and sleep)

--Data cleaning
-- Data will be checked and formatted in the right format
-- check nulls and address appropiately
-- Duplicates will be checked and removed 


--Daily activity cleaning
-----------------------------------------------------------------------------------------format


SELECT TOP (10) *
FROM activity

SELECT Column_name, Data_type
FROM Information_schema.columns
WHERE Table_name = 'activity'

-- each field is stored as string (varchar)
-- create a table that has the formated datatype

CREATE TABLE activity_formatted (
id varchar(20),
activity_day date,
total_steps int,
total_distance float,
tracker_distance float,
logged_activities_distance float,
very_active_distance float,
moderately_Active_distance float, 
light_active_distance float,
sedentary_active_distance float,
very_active_minutes int,
fairly_active_minutes int,
lightly_active_distance int,
sedentary_minutes int,
calories int
)

INSERT INTO activity_formatted
SELECT *
FROM activity


----------------------------------------------------------------------------------------------------------null values

SELECT Column_name, Data_type
FROM Information_schema.columns
WHERE Table_name = 'activity_formatted'


SELECT *
FROM activity_formatted
WHERE NOT (id is null or
activity_day is null or
total_steps is null or
total_distance is null or
tracker_distance is null or
logged_activities_distance is null or
very_active_distance is null or
moderately_Active_distance is null or 
light_active_distance is null or
sedentary_active_distance is null or
very_active_minutes is null or
fairly_active_minutes is null or
lightly_active_distance is null or
sedentary_minutes is null or
calories is null)

-- there are no null values 

-------------------------------------------------------------------------------------------Remove duplicate rows

WITH cte AS  (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY
				id,
				activity_day,
				total_steps,
				total_distance, 
				tracker_distance, 
				logged_activities_distance, 
				very_active_distance ,
				moderately_Active_distance, 
				light_active_distance,
				sedentary_active_distance, 
				very_active_minutes,
				fairly_active_minutes, 
				lightly_active_distance,
				sedentary_minutes,
				calories
				ORDER BY
					id) row_num
FROM activity_formatted
)

SELECT * 
From cte
where row_num > 1


-- No duplicate found


---------------------------------------------------------ANALYZE PHASE-------------------------------------------
-- check the avg of each columns

SELECT
	AVG(total_steps) as avg_total_steps,
	AVG(tracker_distance) as avg_tracker_distance,
	AVG(logged_activities_distance) as avg_logged,
	AVG(very_active_distance) as avg_very_active_distance,
	AVG(moderately_Active_distance) as avg_moderately_active_distance,
	AVG(light_active_distance) as avg_light_active_distance,
	AVG(sedentary_active_distance) as avg_sedentary_activity_distance,
	AVG(very_active_minutes) as avg_very_active_minutes,
	AVG(fairly_active_minutes) as avg_fairly_active_minutes,
	AVG(lightly_active_distance) as avg_lightly_active_minutes,
	AVG(sedentary_minutes) as avg_sedentary_minutes,
	AVG(calories) as avg_calories
FROM activity_formatted

-- The average amount of minutes spent on sedentary activity (Total minutes spent in sedentary activity) is 991 , which is quite much
-- The average lightly minutes (Total minutes spent in light activity) is much more than the active and fairly active minutes
-- The average light active distance(KM travelld doing light activities) is more than the very active and moderately active 





--sleepDay_merged cleaning
SELECT * 
FROM sleepDay_merged

SELECT Column_name, Data_type
FROM Information_schema.columns
WHERE Table_name = 'sleepDay_merged'


-------------------------------------------------------------------convert datatypes(format)


CREATE TABLE sleep_formatted (
id varchar(20),
sleep_day date,
total_sleeps_records int,
total_minutes_asleep int,
total_time_bed int
)

INSERT INTO sleep_formatted
SELECT *
FROM sleepDay_merged


-------------------------------------------------------------------------------check for nulls

SELECT *
FROM sleep_formatted
WHERE NOT (id is null or
sleep_day is null or
total_sleeps_records is null or
total_minutes_asleep is null or
total_time_bed is null)

-- there are no null values


--------------------------------------------------------------------------------check for duplicates

WITH cte AS  (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY
				id,
				sleep_day,
				total_sleeps_records,
				total_minutes_asleep, 
				total_time_bed
				ORDER BY
					id) row_num
FROM sleep_formatted
)

DELETE 
From cte
where row_num > 1

--- 3 duplicates rows found and deleted 

----------------------------------------------------------------------------------analysis
SELECT
	AVG(total_sleeps_records) as avg_total_sleeps,
	AVG(total_minutes_asleep) as avg_total_minutes_asleep,
	AVG(total_time_bed) as avg_total_time_bed,
	(AVG(total_time_bed)-AVG(total_minutes_asleep) ) as restless_awake
FROM sleep_formatted


--women spend an avg of 39 minutes either restless or awake


-----------------------------join the two datasetes(Data aggregation)---------------------------------------


SELECT *
FROM
activity_formatted
JOIN sleep_formatted ON
activity_formatted.id=sleep_formatted.id
AND
activity_formatted.activity_day=sleep_formatted.sleep_day


-------------------------visualizations-----------------------------------
-- we want to exmine the relationships between fields and see how to correlate.
-- we will use the create view function for view later on in tableau

CREATE VIEW steps_vs_calories AS
SELECT
	total_steps,
	calories
FROM activity_formatted

CREATE VIEW sedentary_vs_sleep AS
SELECT
	activity_formatted.sedentary_minutes, sleep_formatted.total_minutes_asleep
FROM
activity_formatted
JOIN sleep_formatted ON
activity_formatted.id=sleep_formatted.id
AND
activity_formatted.activity_day=sleep_formatted.sleep_day


CREATE VIEW very_active_distance_vs_activity_day AS
SELECT
	activity_day,
	very_active_distance
FROM activity_formatted

CREATE VIEW moderately_active_distance_vs_activity_day AS
SELECT
	activity_day,
	moderately_Active_distance
FROM activity_formatted


CREATE VIEW light_active_distance_vs_activity_day AS
SELECT
	activity_day,
	light_active_distance
FROM activity_formatted
