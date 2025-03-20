DECLARE @PropertiesColumns NVARCHAR(MAX);

SELECT @PropertiesColumns = STRING_AGG(QUOTENAME(COLUMN_NAME), ', ')
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Contacts'
  AND COLUMN_NAME NOT IN ('identifier_name', 'identifier_value');

DECLARE @SQL NVARCHAR(MAX) = N'
SELECT
    JSON_QUERY((
        SELECT 
            (
                SELECT 
                    identifier_name AS [type],
                    identifier_value AS [value]
                FOR JSON PATH
            ) AS [identities]
        FOR JSON PATH
    )) AS [identity_profiles],
    JSON_QUERY((
        SELECT ' + @PropertiesColumns + N'
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )) AS [properties]
FROM Contacts
FOR JSON PATH, ROOT(''contacts'')';

EXEC sp_executesql @SQL;