CREATE DATABASE netflix_portfolio;
USE netflix_portfolio;

DROP TABLE IF EXISTS global_streaming_logs;
CREATE TABLE global_streaming_logs (
    log_id INT PRIMARY KEY,
    user_id INT,
    title_name VARCHAR(100),
    genre VARCHAR(50),
    region VARCHAR(50),
    view_date DATETIME,
    minutes_watched INT,
    completed_flag INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/global_streaming_logs.csv'
INTO TABLE global_streaming_logs
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';

#Query 1: Daily Active Users (DAU) & Watch Time
WITH DailyMetrics AS (
    SELECT 
        DATE(view_date) AS stream_date,
        region,
        COUNT(DISTINCT user_id) AS daily_active_users,
        SUM(minutes_watched) / 60 AS total_hours_watched
    FROM global_streaming_logs
    GROUP BY DATE(view_date), region
)
SELECT * FROM DailyMetrics
ORDER BY stream_date DESC, total_hours_watched DESC;

#Query 2: The Netflix "Top 10" Algorithm
WITH TitleStats AS (
    SELECT 
        title_name,
        genre,
        COUNT(log_id) AS total_starts,
        SUM(completed_flag) AS total_completions,
        ROUND((CAST(SUM(completed_flag) AS DECIMAL) / COUNT(log_id)) * 100, 2) AS completion_rate_pct
    FROM global_streaming_logs
    GROUP BY title_name, genre
    HAVING COUNT(log_id) > 1000
)
SELECT 
    title_name,
    genre,
    total_starts,
    completion_rate_pct,
    DENSE_RANK() OVER (ORDER BY completion_rate_pct DESC, total_starts DESC) as global_rank
FROM TitleStats
LIMIT 10;

