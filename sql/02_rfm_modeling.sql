USE rfm_project;

SELECT DATE_ADD(MAX(InvoiceDate), INTERVAL 1 DAY) FROM orders_clean;

SET @analysis_date = '2011-12-10';

CREATE TABLE rfm_table AS
SELECT
    CustomerID,
    DATEDIFF(@analysis_date, MAX(InvoiceDate)) AS Recency,
    COUNT(DISTINCT InvoiceNo) AS Frequency,
    SUM(TotalPrice) AS Monetary
FROM orders_clean
GROUP BY CustomerID;

CREATE TABLE rfm_scores AS
SELECT
    *,
    NTILE(5) OVER (ORDER BY Recency ASC) AS R_Score,
    NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
    NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
FROM rfm_table;

CREATE TABLE rfm_final AS
SELECT *,
    CONCAT(R_Score, F_Score, M_Score) AS RFM_Score,

    CASE
        WHEN R_Score = 5 AND F_Score >= 4 THEN 'Champions'
        WHEN F_Score >= 4 THEN 'Loyal Customers'
        WHEN R_Score >= 4 AND M_Score <= 2 THEN 'Potential'
        WHEN R_Score <= 2 AND F_Score >= 3 THEN 'At Risk'
        WHEN R_Score <= 2 THEN 'Lost'
        ELSE 'Needs Attention'
    END AS Segment

FROM rfm_scores;



