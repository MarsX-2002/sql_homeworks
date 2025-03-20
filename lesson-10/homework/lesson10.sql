;WITH cte AS (
    SELECT 1 AS days
    UNION ALL
    SELECT days + 1 FROM cte
    WHERE days < 40
),
AdjustedTable AS (
    SELECT 
        C.days AS Days,
        ISNULL(S.Num, 0) AS Numbers,
        ROW_NUMBER() OVER (ORDER BY C.days) AS rnk
    FROM 
        cte C
    LEFT JOIN 
        Shipments S ON C.days = S.N
),
cte2 AS (
    SELECT 
        *, 
        COUNT(*) OVER () AS cnt
    FROM 
        AdjustedTable
)
SELECT 
    AVG(Numbers * 1.0) AS Median
FROM 
    cte2
WHERE 
    rnk IN (
        (cnt + 1) / 2,  -- Middle element for odd case
        cnt / 2 + 1     -- Second middle element for even case
    );
