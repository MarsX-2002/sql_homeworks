-- Specify the month by its first day
DECLARE @MonthStart DATE = '2025-03-01';
DECLARE @MonthEnd   DATE = EOMONTH(@MonthStart);

-- Determine the calendar start and end dates so that the month fits into full weeks
-- Assuming DATEFIRST is set to 7 (default) so that Sunday = 1, Monday = 2, ... Saturday = 7
DECLARE @CalendarStart DATE = DATEADD(DAY, -(DATEPART(WEEKDAY, @MonthStart) - 1), @MonthStart);
DECLARE @CalendarEnd   DATE = DATEADD(DAY, (7 - DATEPART(WEEKDAY, @MonthEnd)), @MonthEnd);

-- Build a calendar using a recursive CTE
WITH Calendar AS (
    SELECT @CalendarStart AS CalDate
    UNION ALL
    SELECT DATEADD(DAY, 1, CalDate)
    FROM Calendar
    WHERE CalDate < @CalendarEnd
),
-- For each date, compute the week’s starting date (Sunday) and the day number.
CalendarWeeks AS (
    SELECT 
        CalDate,
        DATEPART(WEEKDAY, CalDate) AS WeekDay,  -- 1 = Sunday, 2 = Monday, ... 7 = Saturday
        DAY(CalDate) AS DayNumber,
        -- The week start is the preceding (or current) Sunday.
        DATEADD(DAY, -(DATEPART(WEEKDAY, CalDate) - 1), CalDate) AS WeekStart
    FROM Calendar
)
SELECT 
    WeekStart,
    MAX(CASE WHEN WeekDay = 1 THEN DayNumber END) AS Sunday,
    MAX(CASE WHEN WeekDay = 2 THEN DayNumber END) AS Monday,
    MAX(CASE WHEN WeekDay = 3 THEN DayNumber END) AS Tuesday,
    MAX(CASE WHEN WeekDay = 4 THEN DayNumber END) AS Wednesday,
    MAX(CASE WHEN WeekDay = 5 THEN DayNumber END) AS Thursday,
    MAX(CASE WHEN WeekDay = 6 THEN DayNumber END) AS Friday,
    MAX(CASE WHEN WeekDay = 7 THEN DayNumber END) AS Saturday
FROM CalendarWeeks
GROUP BY WeekStart
ORDER BY WeekStart
OPTION (MAXRECURSION 0);
