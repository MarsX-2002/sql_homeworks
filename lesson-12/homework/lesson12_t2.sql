IF OBJECT_ID('dbo.GetRoutinesAndParameters', 'P') IS NOT NULL
    DROP PROCEDURE dbo.GetRoutinesAndParameters;
GO

CREATE PROCEDURE dbo.GetRoutinesAndParameters
    @DatabaseName SYSNAME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SQL NVARCHAR(MAX);

    IF @DatabaseName IS NOT NULL
    BEGIN
        SET @SQL = N'
            SELECT 
                ''' + @DatabaseName + ''' AS DatabaseName,
                r.ROUTINE_SCHEMA,
                r.ROUTINE_NAME,
                r.ROUTINE_TYPE,
                p.PARAMETER_NAME,
                p.DATA_TYPE,
                p.CHARACTER_MAXIMUM_LENGTH
            FROM [' + @DatabaseName + '].INFORMATION_SCHEMA.ROUTINES r
            LEFT JOIN [' + @DatabaseName + '].INFORMATION_SCHEMA.PARAMETERS p
                ON r.SPECIFIC_NAME = p.SPECIFIC_NAME
            ORDER BY r.ROUTINE_SCHEMA, r.ROUTINE_NAME, p.ORDINAL_POSITION;
        ';
        EXEC sp_executesql @SQL;
    END
    ELSE
    BEGIN
        SET @SQL = N'';
        
        SELECT @SQL = @SQL + '
            SELECT 
                ''' + name + ''' AS DatabaseName,
                r.ROUTINE_SCHEMA,
                r.ROUTINE_NAME,
                r.ROUTINE_TYPE,
                p.PARAMETER_NAME,
                p.DATA_TYPE,
                p.CHARACTER_MAXIMUM_LENGTH
            FROM [' + name + '].INFORMATION_SCHEMA.ROUTINES r
            LEFT JOIN [' + name + '].INFORMATION_SCHEMA.PARAMETERS p
                ON r.SPECIFIC_NAME = p.SPECIFIC_NAME
            ORDER BY r.ROUTINE_SCHEMA, r.ROUTINE_NAME, p.ORDINAL_POSITION;
        '
        FROM sys.databases
        WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');

        EXEC sp_executesql @SQL;
    END
END
GO
