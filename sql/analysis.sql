/* ---------------------------------------------------------
   Sales strategy analysis
   Goal: understand customer behaviour and how discounts affect sales
   Dataset is small and messy -> Name used as join key
   In real systems a customer_id will be used
--------------------------------------------------------- */


/* 1) First look: ratings across professions
   Idea: check if certain professions are more satisfied
*/
SELECT
    c.Profession,
    COUNT(DISTINCT c.Name) AS Buyers,        -- unique customers
    CAST(AVG(CAST(r.Rating AS FLOAT)) AS DECIMAL(4,2)) AS AvgRating,
    CAST(AVG(CAST(c.[Net Salary (per year)] AS FLOAT)) AS DECIMAL(18,2)) AS AvgSalary
FROM clients c
JOIN reviews r
  ON LOWER(LTRIM(RTRIM(c.Name))) = LOWER(LTRIM(RTRIM(r.Name)))  -- clean join
WHERE c.Profession IS NOT NULL
  AND c.Profession <> '-'
  AND r.Rating IS NOT NULL
  AND c.[Net Salary (per year)] IS NOT NULL
GROUP BY c.Profession
ORDER BY AvgRating DESC;


/* After seeing results:
   higher income professions -> higher rating
   So create segments: Premium / Mid / Low
*/


/* 2) Check how discount periods affect these segments
   Need to compare with normal sales -> baseline daily avg
*/
WITH sales_labeled AS (
    SELECT
        CASE
            WHEN c.Profession IN ('Engineer','Manager','Doctor') THEN 'Premium'
            WHEN c.Profession IN ('Nurse','Teacher','Artist') THEN 'Mid'
            WHEN c.Profession = 'Jobless' THEN 'Low'
        END AS Segment,
        CASE
            WHEN TRY_CONVERT(date, r.[Date of Sale]) BETWEEN '2025-01-01' AND '2025-01-31' THEN 'Winter Sale'
            WHEN TRY_CONVERT(date, r.[Date of Sale]) BETWEEN '2025-07-01' AND '2025-07-31' THEN 'Summer Sale'
            ELSE 'No Discount'
        END AS SalePeriod
    FROM reviews r
    JOIN clients c
      ON LOWER(LTRIM(RTRIM(c.Name))) = LOWER(LTRIM(RTRIM(r.Name)))
    WHERE c.Profession IS NOT NULL
      AND c.Profession <> '-'
),

-- days used to normalize sales to daily average
period_days AS (
    SELECT 'Winter Sale' AS SalePeriod, 31 AS NumDays
    UNION ALL SELECT 'Summer Sale', 31
    UNION ALL SELECT 'No Discount', 303
),

agg AS (
    SELECT
        s.Segment,
        s.SalePeriod,
        COUNT(*) AS UnitsSold,
        d.NumDays,
        CAST(COUNT(*) * 1.0 / d.NumDays AS DECIMAL(18,6)) AS AvgDailySales
    FROM sales_labeled s
    JOIN period_days d ON s.SalePeriod = d.SalePeriod
    WHERE s.Segment IN ('Premium','Mid','Low')
    GROUP BY s.Segment, s.SalePeriod, d.NumDays
),

baseline AS (
    SELECT Segment, AvgDailySales AS BaselineDaily
    FROM agg
    WHERE SalePeriod = 'No Discount'
)

SELECT
    a.Segment,
    a.SalePeriod,
    a.UnitsSold,
    CAST(a.AvgDailySales AS DECIMAL(10,2)) AS AvgDailySales,
    CAST(((a.AvgDailySales / NULLIF(b.BaselineDaily,0)) - 1) * 100.0 AS DECIMAL(10,2)) AS PercentChangeVsNoDiscount
FROM agg a
JOIN baseline b ON a.Segment = b.Segment
ORDER BY
    CASE a.Segment WHEN 'Premium' THEN 1 WHEN 'Mid' THEN 2 WHEN 'Low' THEN 3 END,
    CASE a.SalePeriod WHEN 'Winter Sale' THEN 1 WHEN 'Summer Sale' THEN 2 ELSE 3 END;


/* Observed:
   Summer sale helps premium a lot, winter hurts both
   Low segment barely reacts
*/


/* 3) Check color preference per segment
   Not rating difference -> buying preference
*/
WITH seg_color AS (
    SELECT
        CASE
            WHEN c.Profession IN ('Engineer','Manager','Doctor') THEN 'Premium'
            WHEN c.Profession IN ('Nurse','Teacher','Artist') THEN 'Mid'
            WHEN c.Profession = 'Jobless' THEN 'Low'
        END AS Segment,
        r.[Product Color] AS ProductColor,
        COUNT(*) AS UnitsSold,
        CAST(AVG(CAST(r.Rating AS FLOAT)) AS DECIMAL(4,2)) AS AvgRating
    FROM clients c
    JOIN reviews r
      ON LOWER(LTRIM(RTRIM(c.Name))) = LOWER(LTRIM(RTRIM(r.Name)))
    WHERE c.Profession IS NOT NULL
      AND c.Profession <> '-'
      AND r.[Product Color] IS NOT NULL
      AND r.Rating IS NOT NULL
    GROUP BY
        CASE
            WHEN c.Profession IN ('Engineer','Manager','Doctor') THEN 'Premium'
            WHEN c.Profession IN ('Nurse','Teacher','Artist') THEN 'Mid'
            WHEN c.Profession = 'Jobless' THEN 'Low'
        END,
        r.[Product Color]
)

SELECT
    Segment,
    ProductColor,
    UnitsSold,
    AvgRating,
    SUM(UnitsSold) OVER (PARTITION BY Segment) AS TotalUnits
FROM seg_color
ORDER BY
    CASE Segment WHEN 'Premium' THEN 1 WHEN 'Mid' THEN 2 WHEN 'Low' THEN 3 END,
    UnitsSold DESC;

