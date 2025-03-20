CREATE PROCEDURE dbo.GetRoutinesAndParameters
    @DatabaseName SYSNAME = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @DatabaseName IS NOT NULL
    BEGIN
        DECLARE @sql NVARCHAR(MAX);

        SET @sql = N'
        USE [' + QUOTENAME(@DatabaseName) + N'];
        SELECT 
            ''' + @DatabaseName + N''' AS DatabaseName,
            r.ROUTINE_SCHEMA AS SchemaName,
            r.ROUTINE_NAME AS RoutineName,
            r.ROUTINE_TYPE AS RoutineType,
            p.PARAMETER_NAME AS ParameterName,
            p.DATA_TYPE AS ParameterDataType,
            p.CHARACTER_MAXIMUM_LENGTH AS ParameterMaxLength
        FROM INFORMATION_SCHEMA.ROUTINES r
        LEFT JOIN INFORMATION_SCHEMA.PARAMETERS p
            ON r.SPECIFIC_NAME = p.SPECIFIC_NAME
        ORDER BY r.ROUTINE_SCHEMA, r.ROUTINE_NAME, p.ORDINAL_POSITION;';
        
        EXEC sp_executesql @sql;
    END
    ELSE
    BEGIN
        -- Using sp_MSforeachdb to loop through all non-system databases
        DECLARE @cmd NVARCHAR(MAX) = N' 
        IF DB_ID(''?'' ) NOT IN (DB_ID(''master''), DB_ID(''tempdb''), DB_ID(''model''), DB_ID(''msdb''))
        BEGIN
            USE [?];
            SELECT 
                DB_NAME() AS DatabaseName,
                r.ROUTINE_SCHEMA AS SchemaName,
                r.ROUTINE_NAME AS RoutineName,
                r.ROUTINE_TYPE AS RoutineType,
                p.PARAMETER_NAME AS ParameterName,
                p.DATA_TYPE AS ParameterDataType,
                p.CHARACTER_MAXIMUM_LENGTH AS ParameterMaxLength
            FROM INFORMATION_SCHEMA.ROUTINES r
            LEFT JOIN INFORMATION_SCHEMA.PARAMETERS p
                ON r.SPECIFIC_NAME = p.SPECIFIC_NAME
            ORDER BY r.ROUTINE_SCHEMA, r.ROUTINE_NAME, p.ORDINAL_POSITION;
        END';
        
        EXEC sp_MSforeachdb @cmd;
    END
END
GO
