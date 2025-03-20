EXEC sp_MSforeachdb '
IF ''?'' NOT IN (''master'', ''tempdb'', ''model'', ''msdb'')
BEGIN
    USE [?];
    SELECT 
        ''?'' AS DatabaseName,
        s.name AS SchemaName,
        t.name AS TableName,
        c.name AS ColumnName,
        ty.name AS DataType
    FROM sys.tables t
    INNER JOIN sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN sys.columns c ON t.object_id = c.object_id
    INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
    ORDER BY s.name, t.name, c.column_id;
END';
