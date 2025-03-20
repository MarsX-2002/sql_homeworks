DECLARE @SQL NVARCHAR(MAX) = N'';

SELECT @SQL = @SQL + '
    SELECT 
        ''' + name + ''' AS DatabaseName,
        s.name AS SchemaName,
        t.name AS TableName,
        c.name AS ColumnName,
        ty.name AS DataType
    FROM [' + name + '].sys.tables t
    INNER JOIN [' + name + '].sys.schemas s ON t.schema_id = s.schema_id
    INNER JOIN [' + name + '].sys.columns c ON t.object_id = c.object_id
    INNER JOIN [' + name + '].sys.types ty ON c.user_type_id = ty.user_type_id
    ORDER BY s.name, t.name, c.column_id;
'
FROM sys.databases
WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb');

EXEC sp_executesql @SQL;
