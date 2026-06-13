CREATE DATABASE uber_analysis;
USE uber_analysis;

-- OVERVIEW OF DATA

SELECT * from uber_small;

SELECT COUNT(*) total_records
from uber_small;

-- Insight
-- The dataset contains 19,999 trip records, providing a substantial sample for analyzing ride patterns, revenue generation, customer behavior, and operational efficiency.
-- The dataset is large enough to identify meaningful trends while remaining manageable for SQL-based analysis.


-- data quality check
-- checking null values
SELECT
SUM(CASE WHEN trip_distance IS NULL THEN 1 ELSE 0 END) AS trip_distance_nulls,
SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS payment_type_nulls,
SUM(CASE WHEN fare_amount IS NULL THEN 1 ELSE 0 END) AS fare_amount_nulls
FROM uber_small;

-- Insight
-- No significant missing values were identified in critical fields such as trip distance, fare amount, and payment type.
-- This indicates good data completeness and reduces the need for extensive data imputation.

-- 2. Data Quality Checks  
SELECT *
FROM uber_small
WHERE trip_distance < 0
OR fare_amount < 0
OR total_amount < 0;  
  
--   Insight
-- No records contained negative trip distances, fares, or total amounts.
-- This suggests that the dataset has been validated and contains logically consistent transactional data.



-- (2a)Zero Distance Trips
SELECT COUNT(*) AS zero_distance_trips
FROM uber_small
WHERE trip_distance = 0;
  

-- (2b)  Fare Mismatch 
SELECT *
FROM uber_small
WHERE ABS(total_amount - calculated_total_amount) > 1;

-- 3. Descriptive Statistics
-- 3a Trip Distance Statistics
SELECT
MIN(trip_distance) AS min_distance,
MAX(trip_distance) AS max_distance,
AVG(trip_distance) AS avg_distance
FROM uber_small;

-- Results

-- Minimum Distance: 0.01 miles
-- Maximum Distance: 72.30 miles
-- Average Distance: 9.14 miles
-- Insight
-- Most rides fall within typical urban travel ranges, while some long-distance trips significantly increase the maximum trip distance.
-- The average trip length of approximately 9 miles indicates a mix of short city rides and airport/intercity journeys.

-- 3b Revenue Statistics
SELECT
MIN(total_amount),
MAX(total_amount),
AVG(total_amount),
SUM(total_amount)
FROM uber_small;

-- Results

-- Minimum Fare: $3.79
-- Maximum Fare: $450.30
-- Average Fare: $42.58
-- Total Revenue: $851,693.38
-- Insight
-- Revenue distribution is highly varied, with premium long-distance trips contributing substantially to overall revenue.
-- The average trip generates approximately $42.58, suggesting healthy fare generation across the dataset.



-- 4. Revenue Analysis
-- a,Total Revenue
SELECT SUM(total_amount) AS total_revenue
FROM uber_small;


-- b,Monthly Revenue
SELECT
month,
SUM(total_amount) AS revenue
FROM uber_small
GROUP BY month
ORDER BY month;

-- c, Daily Revenue
SELECT
day_of_week,
SUM(total_amount) AS revenue
FROM uber_small
GROUP BY day_of_week
ORDER BY revenue DESC;

-- 5. Payment Analysis
-- a Payment Method Usage
SELECT
payment_type,
COUNT(*) AS trips
FROM uber_small
GROUP BY payment_type
ORDER BY trips DESC;

-- Results

-- Payment Type 1 accounts for all recorded trips.
-- Insight
-- The dataset appears to contain only one payment category, limiting comparative payment analysis.
-- Future datasets with multiple payment methods could provide deeper insights into customer payment preferences.

-- b Revenue by Payment Type
SELECT
payment_type,
SUM(total_amount) AS revenue
FROM uber_small
GROUP BY payment_type
ORDER BY revenue DESC;

-- Insight
-- Since all trips belong to a single payment category, all revenue is generated through that payment method.
-- No meaningful comparison can be performed between payment channels.

-- 6. Time-Based Analysis
 
-- Peak Hours 
SELECT
hour_of_day,
COUNT(*) AS trips
FROM uber_small
GROUP BY hour_of_day
ORDER BY trips DESC;

-- -Top Hours

-- 9 PM (21:00)
-- 10 PM (22:00)
-- 5 PM (17:00)
-- 8 PM (20:00)
-- Insight
-- Demand is highest during evening hours.
-- This pattern suggests increased ride requests due to commuting, social activities, dining, and nightlife.
-- Driver allocation during evening periods could significantly improve service efficiency and revenue generation.

-- b Peak Days
SELECT
day_of_week,
COUNT(*) AS trips
FROM uber_small
GROUP BY day_of_week
ORDER BY trips DESC;

-- Top Days

-- Day 3
-- Day 2
-- Day 1
-- Day 4
-- Insight
-- Ride demand is concentrated on specific weekdays.
-- Understanding these peak-demand days can help optimize driver scheduling and surge pricing strategies.

-- 7. Location Analysis
-- a,Top Pickup Locations

SELECT
pickup_location_id,
COUNT(*) AS trips
FROM uber_small
GROUP BY pickup_location_id
ORDER BY trips DESC
LIMIT 10;

-- Top Pickup Locations

-- Location 138
-- Location 132
-- Location 161
-- Insight
-- Pickup demand is highly concentrated around a small number of locations.
-- These locations likely represent major transportation hubs, airports, commercial centers, or densely populated regions.
-- Strategic driver placement in these areas could reduce passenger wait times.

-- Top Dropoff Locations
SELECT
dropoff_location_id,
COUNT(*) AS trips
FROM uber_small
GROUP BY dropoff_location_id
ORDER BY trips DESC
LIMIT 10;

-- Top Dropoff Locations

-- Location 138
-- Location 161
-- Location 230
-- Insight
-- The same locations frequently appear as both pickup and dropoff points.
-- This indicates strong ride circulation within key business and transportation zones.

-- 8. Distance Analysis
-- Distance Categories
SELECT
CASE
WHEN trip_distance < 2 THEN 'Short'
WHEN trip_distance < 5 THEN 'Medium'
ELSE 'Long'
END AS trip_type,
COUNT(*) AS trips
FROM uber_small
GROUP BY trip_type;

-- Results

-- Long Trips: 17,821
-- Medium Trips: 1,651
-- Short Trips: 527
-- Insight
-- Long-distance trips account for the overwhelming majority of rides.
-- This suggests that the dataset may focus on airport transfers, suburban travel, or intercity transportation rather than short urban rides.
-- Long-distance rides are likely the primary revenue driver.


-- Average Fare by Distance

SELECT
ROUND(AVG(trip_distance),2) AS avg_distance,
ROUND(AVG(total_amount),2) AS avg_fare
FROM uber_small;

-- Results

-- Average Distance: 9.14 miles
-- Average Fare: $42.59
-- Insight
-- Fare values increase proportionally with travel distance.
-- The observed relationship indicates a consistent pricing structure and provides a strong foundation for fare prediction models.
-- 9. Tip Analysis
-- Highest Tipping Payment Type

SELECT
payment_type,
AVG(tip_amount) AS avg_tip
FROM uber_small
GROUP BY payment_type
ORDER BY avg_tip DESC;

-- Results

-- Average Tip: $7.19
-- Insight
-- Customers provide substantial tips on average, representing a meaningful portion of driver earnings.
-- Tip behavior could be further analyzed using factors such as trip distance, trip duration, and time of day.



-- 10. Trip Duration Analysis
-- Average Duration
SELECT AVG(trip_duration)
FROM uber_small;

-- Results

-- Average Duration: 2141 seconds (~35.7 minutes)
-- Insight
-- The average trip lasts approximately 36 minutes, supporting the observation that most rides are medium-to-long distance journeys.
-- Duration appears consistent with the average trip distance recorded in the dataset.

-- Longest Trips
SELECT *
FROM uber_small
ORDER BY trip_duration DESC
LIMIT 10;


-- 11. Business Analyst KPIs
-- Revenue per Trip
SELECT
SUM(total_amount)/COUNT(*) AS revenue_per_trip
FROM uber_small;

-- Results

-- Revenue per Trip: $42.59
-- Insight
-- Each completed ride generates approximately $42.59 in revenue on average.
-- This metric can serve as a key business KPI for evaluating profitability and operational performance.


-- Average Revenue by Hour
SELECT
hour_of_day,
AVG(total_amount) AS avg_revenue
FROM uber_small
GROUP BY hour_of_day
ORDER BY avg_revenue DESC;

-- Top Revenue Hours

-- 5 AM
-- 6 AM
-- 4 PM
-- Insight
-- While ride volume peaks during the evening, the highest average revenue occurs during early morning and late afternoon periods.
-- This suggests that longer or higher-value trips occur during these hours, potentially due to airport transfers and commuter traffic.


-- 12. Advanced SQL
-- Running Revenue
SELECT
month,
SUM(total_amount) AS revenue,
SUM(SUM(total_amount))
OVER(ORDER BY month) AS cumulative_revenue
FROM uber_small
GROUP BY month;


-- Revenue Ranking by Location
SELECT
pickup_location_id,
SUM(total_amount) AS revenue,
RANK() OVER(ORDER BY SUM(total_amount) DESC) AS rank_no
FROM uber_small
GROUP BY pickup_location_id;



-- Top 5 Revenue Locations
WITH location_revenue AS
(
SELECT
pickup_location_id,
SUM(total_amount) AS revenue
FROM uber_small
GROUP BY pickup_location_id
)
SELECT *
FROM location_revenue
ORDER BY revenue DESC
LIMIT 5;

-- Top Revenue Locations

-- Location 138 – $254,449
-- Location 132 – $79,365
-- Location 230 – $26,968
-- Insight
-- Revenue is heavily concentrated in a few locations.
-- Location 138 alone contributes a significant share of total revenue, making it a strategically important service area.
-- Focused marketing and driver allocation in these locations could maximize profitability.


-- Final Project Conclusion
-- Conclusion
-- The Uber trip dataset demonstrates strong revenue generation, with an average fare of $42.59 per trip and total revenue exceeding $851,000.
-- Demand is highest during evening hours, while the greatest average revenue is generated during early morning and afternoon periods.
-- A small number of pickup locations account for a large share of both trips and revenue, highlighting the importance of geographic demand concentration.
-- The dataset exhibits high data quality with minimal inconsistencies, making it suitable for advanced analytics, business intelligence reporting, 
   -- and machine learning applications such as fare prediction, demand forecasting, and trip duration estimation.





