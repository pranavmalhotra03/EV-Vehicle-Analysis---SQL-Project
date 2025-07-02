CREATE DATABASE PROJECTS;

USE PROJECTS;

SELECT * FROM EV_SPECS;


-- Get the total number of unique EV models in the dataset
SELECT COUNT(DISTINCT model) AS total_models FROM ev_specs;


-- Find the top 10 EVs with the highest range (km)
SELECT TOP 10 brand, model, range_km
FROM ev_specs
ORDER BY range_km DESC;


-- Compare average battery size across different car body types
SELECT car_body_type, ROUND(AVG(battery_capacity_kWh), 2) AS avg_battery_kWh
FROM ev_specs
GROUP BY car_body_type
ORDER BY avg_battery_kWh DESC;


-- Find the 5 most energy-efficient EVs based on consumption per km
SELECT TOP 5 brand, model, efficiency_wh_per_km
FROM ev_specs
WHERE efficiency_wh_per_km IS NOT NULL
ORDER BY efficiency_wh_per_km ASC;


-- Find EVs suitable for larger families
SELECT brand, model, seats
FROM ev_specs
WHERE seats >= 7
ORDER BY seats DESC;


-- Identify brands with the highest number of EVs in the dataset
SELECT brand, COUNT(*) AS model_count
FROM ev_specs
GROUP BY brand
ORDER BY model_count DESC;


-- Compare 0–100 km/h acceleration times across drivetrain types
SELECT drivetrain, ROUND(AVG(acceleration_0_100_s), 2) AS avg_acceleration
FROM ev_specs
WHERE acceleration_0_100_s IS NOT NULL
GROUP BY drivetrain
ORDER BY avg_acceleration;


-- List EVs that support DC fast charging (with power rating)
SELECT brand, model, fast_charging_power_kw_dc
FROM ev_specs
WHERE fast_charging_power_kw_dc IS NOT NULL
ORDER BY fast_charging_power_kw_dc DESC;


-- Analyze range by segment (luxury, compact, etc.)
SELECT segment, ROUND(AVG(range_km), 2) AS avg_range
FROM ev_specs
GROUP BY segment
ORDER BY avg_range DESC;


-- See how many EVs use each drivetrain type (AWD, RWD, etc.)
SELECT drivetrain, COUNT(*) AS total
FROM ev_specs
GROUP BY drivetrain
ORDER BY total DESC;


-- See how many EVs use each drivetrain type (AWD, RWD, etc.)
SELECT drivetrain, COUNT(*) AS total
FROM ev_specs
GROUP BY drivetrain
ORDER BY total DESC;


-- Use a CTE to rank EVs by range within each car body type, then filter the top 3
WITH RankedEVs AS (
  SELECT brand, model, car_body_type, range_km,
         RANK() OVER (PARTITION BY car_body_type ORDER BY range_km DESC) AS rnk
  FROM ev_specs
)
SELECT *
FROM RankedEVs
WHERE rnk <= 3;


-- Compare an EV’s range to the average range of all EVs from the same brand
SELECT brand, model, range_km,
       ROUND(AVG(range_km) OVER (PARTITION BY brand), 2) AS avg_brand_range
FROM ev_specs
ORDER BY brand;


-- Show EVs that accelerate faster than the average 0–100 km/h time
SELECT brand, model, acceleration_0_100_s
FROM ev_specs
WHERE acceleration_0_100_s < (
    SELECT AVG(acceleration_0_100_s)
    FROM ev_specs
    WHERE acceleration_0_100_s IS NOT NULL
)
ORDER BY acceleration_0_100_s;


-- Rank EVs by cargo volume using ROW_NUMBER() to get unique ordering
SELECT ROW_NUMBER() OVER (ORDER BY cargo_volume_l DESC) AS cargo_rank,
       brand, model, cargo_volume_l
FROM ev_specs
WHERE cargo_volume_l IS NOT NULL;


-- Calculate a performance score combining range, efficiency, top speed, and acceleration
WITH ScoreCTE AS (
  SELECT brand, model,
         (1.0 * range_km / efficiency_wh_per_km) + (1.0 * top_speed_kmh / acceleration_0_100_s) AS performance_score
  FROM ev_specs
  WHERE efficiency_wh_per_km > 0 AND acceleration_0_100_s > 0
)


-- Return top 10 EVs with the highest performance score
SELECT TOP 10 brand, model, ROUND(performance_score, 2) AS score
FROM ScoreCTE
ORDER BY score DESC;


-- For each brand, show the EV(s) with the maximum length
SELECT brand, model, length_mm
FROM ev_specs e
WHERE length_mm = (
  SELECT MAX(length_mm)
  FROM ev_specs
  WHERE brand = e.brand
);


-- Use a CTE to filter EVs that support fast DC charging, then group them by segment
WITH FastChargers AS (
  SELECT segment
  FROM ev_specs
  WHERE fast_charging_power_kw_dc IS NOT NULL
)
SELECT segment, COUNT(*) AS fast_charge_models
FROM FastChargers
GROUP BY segment
ORDER BY fast_charge_models DESC;


-- Divide EVs into four quartiles based on acceleration time (lower is better)
SELECT brand, model, acceleration_0_100_s,
       NTILE(4) OVER (ORDER BY acceleration_0_100_s ASC) AS acceleration_quartile
FROM ev_specs
WHERE acceleration_0_100_s IS NOT NULL;


-- Calculate percentile rank of energy efficiency within each vehicle segment
SELECT brand, model, segment, efficiency_wh_per_km,
       PERCENT_RANK() OVER (PARTITION BY segment ORDER BY efficiency_wh_per_km ASC) AS efficiency_rank
FROM ev_specs
WHERE efficiency_wh_per_km IS NOT NULL;










