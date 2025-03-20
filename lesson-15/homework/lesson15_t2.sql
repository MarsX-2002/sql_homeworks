-- Drop the table if it exists
DROP TABLE IF EXISTS items;
GO

-- Create the items table
CREATE TABLE items (
    ID VARCHAR(10),
    CurrentQuantity INT,
    QuantityChange INT,
    ChangeType VARCHAR(10),
    change_datetime DATETIME
);
GO

-- Insert sample data
INSERT INTO items VALUES
('A0013', 278,   99 ,   'out', '2020-05-25 0:25'), 
('A0012', 377,   31 ,   'in',  '2020-05-24 22:00'),
('A0011', 346,   1  ,   'out', '2020-05-24 15:01'),
('A0010', 347,   1  ,   'out', '2020-05-23 5:00'),
('A009',  348,   102,   'in',  '2020-04-25 18:00'),
('A008',  246,   43 ,   'in',  '2020-04-25 2:00'),
('A007',  203,   2  ,   'out', '2020-02-25 9:00'),
('A006',  205,   129,   'out', '2020-02-18 7:00'),
('A005',  334,   1  ,   'out', '2020-02-18 6:00'),
('A004',  335,   27 ,   'out', '2020-01-29 5:00'),
('A003',  362,   120,   'in',  '2019-12-31 2:00'),
('A002',  242,   8  ,   'out', '2019-05-22 0:50'),
('A001',  250,   250,   'in',  '2019-05-20 0:45');
GO

-- Declare variables for the latest date
DECLARE @LatestDate DATETIME;
SELECT @LatestDate = MAX(change_datetime) FROM items;

-- Table variable to track inventory batches
DECLARE @InBatches TABLE (
    BatchID INT IDENTITY(1,1) PRIMARY KEY,
    InDate DATETIME,
    OriginalQty INT,
    RemainingQty INT
);

-- Table variable to track age bucket quantities
DECLARE @AgeBuckets TABLE (
    Bucket VARCHAR(50),
    Quantity INT
);

-- Process each event in chronological order
DECLARE @ID VARCHAR(10), @CurrentQty INT, @QtyChange INT, @ChangeType VARCHAR(10), @ChangeDt DATETIME;
DECLARE eventCursor CURSOR FOR 
    SELECT ID, CurrentQuantity, QuantityChange, ChangeType, change_datetime
    FROM items
    ORDER BY change_datetime;

OPEN eventCursor;
FETCH NEXT FROM eventCursor INTO @ID, @CurrentQty, @QtyChange, @ChangeType, @ChangeDt;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF @ChangeType = 'in'
    BEGIN
        INSERT INTO @InBatches (InDate, OriginalQty, RemainingQty)
        VALUES (@ChangeDt, @QtyChange, @QtyChange);
    END
    ELSE IF @ChangeType = 'out'
    BEGIN
        DECLARE @OutQtyRemaining INT = @QtyChange;
        WHILE @OutQtyRemaining > 0
        BEGIN
            DECLARE @BatchID INT, @InDate DATETIME, @Remaining INT;
            SELECT TOP 1 @BatchID = BatchID, @InDate = InDate, @Remaining = RemainingQty
            FROM @InBatches
            ORDER BY BatchID;

            IF @@ROWCOUNT = 0 BREAK;

            DECLARE @Deduct INT = CASE WHEN @Remaining >= @OutQtyRemaining THEN @OutQtyRemaining ELSE @Remaining END;
            DECLARE @Days INT = DATEDIFF(DAY, @InDate, @ChangeDt);
            DECLARE @Bucket VARCHAR(50);

            SET @Bucket = CASE 
                WHEN @Days BETWEEN 1 AND 90 THEN '1-90'
                WHEN @Days BETWEEN 91 AND 180 THEN '91-180'
                WHEN @Days BETWEEN 181 AND 270 THEN '181-270'
                WHEN @Days BETWEEN 271 AND 360 THEN '271-360'
                WHEN @Days >= 361 THEN '361-450'
                ELSE '0'
            END;

            IF @Bucket != '0'
            BEGIN
                IF EXISTS (SELECT 1 FROM @AgeBuckets WHERE Bucket = @Bucket)
                    UPDATE @AgeBuckets SET Quantity += @Deduct WHERE Bucket = @Bucket;
                ELSE
                    INSERT INTO @AgeBuckets (Bucket, Quantity) VALUES (@Bucket, @Deduct);
            END

            UPDATE @InBatches SET RemainingQty -= @Deduct WHERE BatchID = @BatchID;
            IF (SELECT RemainingQty FROM @InBatches WHERE BatchID = @BatchID) = 0
                DELETE FROM @InBatches WHERE BatchID = @BatchID;

            SET @OutQtyRemaining -= @Deduct;
        END
    END

    FETCH NEXT FROM eventCursor INTO @ID, @CurrentQty, @QtyChange, @ChangeType, @ChangeDt;
END

CLOSE eventCursor;
DEALLOCATE eventCursor;

-- Process remaining batches
DECLARE remainingCursor CURSOR FOR 
    SELECT InDate, RemainingQty FROM @InBatches;
OPEN remainingCursor;

FETCH NEXT FROM remainingCursor INTO @InDate, @QtyChange;
WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @DaysRem INT = DATEDIFF(DAY, @InDate, @LatestDate);
    DECLARE @RemBucket VARCHAR(50) = CASE 
        WHEN @DaysRem BETWEEN 0 AND 90 THEN '1-90'
        WHEN @DaysRem BETWEEN 91 AND 180 THEN '91-180'
        WHEN @DaysRem BETWEEN 181 AND 270 THEN '181-270'
        WHEN @DaysRem BETWEEN 271 AND 360 THEN '271-360'
        WHEN @DaysRem >= 361 THEN '361-450'
        ELSE '0'
    END;

    IF @RemBucket != '0'
    BEGIN
        IF EXISTS (SELECT 1 FROM @AgeBuckets WHERE Bucket = @RemBucket)
            UPDATE @AgeBuckets SET Quantity += @QtyChange WHERE Bucket = @RemBucket;
        ELSE
            INSERT INTO @AgeBuckets (Bucket, Quantity) VALUES (@RemBucket, @QtyChange);
    END

    FETCH NEXT FROM remainingCursor INTO @InDate, @QtyChange;
END

CLOSE remainingCursor;
DEALLOCATE remainingCursor;

-- Pivot the results into the desired format
SELECT 
    ISNULL([1-90], 0) AS [1-90 days old],
    ISNULL([91-180], 0) AS [91-180 days old],
    ISNULL([181-270], 0) AS [181-270 days old],
    ISNULL([271-360], 0) AS [271-360 days old],
    ISNULL([361-450], 0) AS [361-450 days old]
FROM (
    SELECT Bucket, Quantity FROM @AgeBuckets
) AS SourceTable
PIVOT (
    SUM(Quantity) FOR Bucket IN ([1-90], [91-180], [181-270], [271-360], [361-450])
) AS PivotTable;