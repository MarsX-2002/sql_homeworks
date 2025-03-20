-----------------------------
-- 1. Create sample table
-----------------------------
DROP TABLE IF EXISTS items;
GO

CREATE TABLE items
(
	ID						varchar(10),
	CurrentQuantity			int,
	QuantityChange   		int,
	ChangeType				varchar(10),
	Change_datetime			datetime
);
GO

INSERT INTO items VALUES
('A0013', 278,   99 ,   'out', '2020-05-25 00:25'), 
('A0012', 377,   31 ,   'in',  '2020-05-24 22:00'),
('A0011', 346,   1  ,   'out', '2020-05-24 15:01'),
('A0010', 347,   1  ,   'out', '2020-05-23 05:00'),
('A009',  348,   102,   'in',  '2020-04-25 18:00'),
('A008',  246,   43 ,   'in',  '2020-04-25 02:00'),
('A007',  203,   2  ,   'out', '2020-02-25 09:00'),
('A006',  205,   129,   'out', '2020-02-18 07:00'),
('A005',  334,   1  ,   'out', '2020-02-18 06:00'),
('A004',  335,   27 ,   'out', '2020-01-29 05:00'),
('A003',  362,   120,   'in',  '2019-12-31 02:00'),
('A002',  242,   8  ,   'out', '2019-05-22 00:50'),
('A001',  250,   250,   'in',  '2019-05-20 00:45');

SELECT * FROM items;
GO

/*
The logic:
1. Process transactions in ascending order of Change_datetime.
2. For an "in" transaction, add a new “lot” with its arrival date and quantity.
3. For an "out" transaction, remove (FIFO) from the oldest lot(s) and record the quantity and its “age” (the number of days between the lot’s arrival date and the out transaction date).
4. After processing all transactions, assign the remaining lots an age using the analysis date (here, the last change_datetime = 2020‑05‑25).
5. Finally, group all allocated quantities (both from out transactions and remaining inventory) into 90‑day intervals.
*/

-------------------------------------------------------
-- 2. FIFO allocation, aging, and bucketing solution
-------------------------------------------------------
-- Table variable to hold “in” lots for FIFO processing
DECLARE @FIFO TABLE (
    LotID       int IDENTITY(1,1),
    ArrivalDate datetime,
    QtyRemaining int
);

-- Table variable to record the “age” for each allocation (whether items left or are still in inventory)
DECLARE @Allocations TABLE (
    Qty     int,
    AgeDays int
);

-- Cursor to process transactions in order
DECLARE trans_cursor CURSOR FOR
    SELECT ChangeType, QuantityChange, Change_datetime
    FROM items
    ORDER BY Change_datetime, (CASE WHEN ChangeType = 'in' THEN 0 ELSE 1 END);  
    -- if transactions occur at the same time, process "in" before "out"

OPEN trans_cursor;

DECLARE @type varchar(10), @qty int, @TransDate datetime;

WHILE 1 = 1
BEGIN
    FETCH NEXT FROM trans_cursor INTO @type, @qty, @TransDate;
    IF @@FETCH_STATUS <> 0 
        BREAK;

    IF @type = 'in'
    BEGIN
        -- For an "in" transaction, add a new lot
        INSERT INTO @FIFO (ArrivalDate, QtyRemaining)
        VALUES (@TransDate, @qty);
    END
    ELSE IF @type = 'out'
    BEGIN
        DECLARE @CurrentOutQty int = @qty;
        
        -- For an "out" transaction, remove from FIFO lots
        WHILE @CurrentOutQty > 0
        BEGIN
            DECLARE @LotID int, @LotArrival datetime, @LotQty int;
            SELECT TOP 1 
                   @LotID = LotID, 
                   @LotArrival = ArrivalDate, 
                   @LotQty = QtyRemaining
            FROM @FIFO
            ORDER BY ArrivalDate;
            
            IF @LotQty > @CurrentOutQty
            BEGIN
                -- Allocate part of this lot
                INSERT INTO @Allocations (Qty, AgeDays)
                VALUES (@CurrentOutQty, DATEDIFF(day, @LotArrival, @TransDate));
                
                UPDATE @FIFO 
                SET QtyRemaining = QtyRemaining - @CurrentOutQty
                WHERE LotID = @LotID;
                
                SET @CurrentOutQty = 0;
            END
            ELSE
            BEGIN
                -- Allocate the whole lot and remove it
                INSERT INTO @Allocations (Qty, AgeDays)
                VALUES (@LotQty, DATEDIFF(day, @LotArrival, @TransDate));
                
                SET @CurrentOutQty = @CurrentOutQty - @LotQty;
                
                DELETE FROM @FIFO WHERE LotID = @LotID;
            END
        END
    END
END

CLOSE trans_cursor;
DEALLOCATE trans_cursor;

-- Determine the analysis date (use the latest transaction date)
DECLARE @AnalysisDate datetime;
SELECT @AnalysisDate = MAX(Change_datetime) FROM items;

-- For each remaining lot (i.e. inventory still in the warehouse), record an allocation using the analysis date
INSERT INTO @Allocations (Qty, AgeDays)
SELECT QtyRemaining, DATEDIFF(day, ArrivalDate, @AnalysisDate)
FROM @FIFO;

-- Finally, aggregate the allocations into 90‑day age buckets.
-- (Note: the buckets are: 1-90, 91-180, 181-270, 271-360, 361-450)
SELECT
    SUM(CASE WHEN AgeDays BETWEEN 1   AND 90  THEN Qty ELSE 0 END) AS [1-90 days old],
    SUM(CASE WHEN AgeDays BETWEEN 91  AND 180 THEN Qty ELSE 0 END) AS [91-180 days old],
    SUM(CASE WHEN AgeDays BETWEEN 181 AND 270 THEN Qty ELSE 0 END) AS [181-270 days old],
    SUM(CASE WHEN AgeDays BETWEEN 271 AND 360 THEN Qty ELSE 0 END) AS [271-360 days old],
    SUM(CASE WHEN AgeDays BETWEEN 361 AND 450 THEN Qty ELSE 0 END) AS [361-450 days old]
FROM @Allocations;
GO
