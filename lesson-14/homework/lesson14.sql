BEGIN TRY
    -- Build an HTML table with index metadata
    DECLARE @HTMLBody NVARCHAR(MAX);

    -- Start of HTML content, including styling for alternating rows
    SET @HTMLBody = 
    '<html>
    <head>
        <style>
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #999; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
            tr:nth-child(even) { background-color: #f9f9f9; }
        </style>
    </head>
    <body>
    <h2>Index Metadata Report</h2>
    <table>
        <tr>
            <th>Table Name</th>
            <th>Index Name</th>
            <th>Index Type</th>
            <th>Column Type</th>
        </tr>';

    -- Append table rows from index metadata using a CTE
    ;WITH IndexMeta AS (
        SELECT 
            t.name AS TableName,
            i.name AS IndexName,
            i.type_desc AS IndexType,
            ty.name AS ColumnType,
            ic.key_ordinal
        FROM sys.indexes i
        INNER JOIN sys.tables t ON i.object_id = t.object_id
        INNER JOIN sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
        INNER JOIN sys.columns c ON c.object_id = t.object_id AND c.column_id = ic.column_id
        INNER JOIN sys.types ty ON c.user_type_id = ty.user_type_id
    )
    SELECT @HTMLBody = @HTMLBody + 
    (
        SELECT 
            '<tr>' +
            '<td>' + TableName + '</td>' +
            '<td>' + IndexName + '</td>' +
            '<td>' + IndexType + '</td>' +
            '<td>' + ColumnType + '</td>' +
            '</tr>'
        FROM IndexMeta
        ORDER BY TableName, IndexName, key_ordinal
        FOR XML PATH(''), TYPE
    ).value('.', 'NVARCHAR(MAX)');

    -- Close the HTML tags
    SET @HTMLBody = @HTMLBody + '</table></body></html>';

    -- Send the email using Database Mail
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = 'MyMailProfile',  -- Replace with your valid profile name
        @recipients = 'mirjalol0331@gmail.com',  
        @subject = 'Index Metadata Report',
        @body = @HTMLBody,
        @body_format = 'HTML';
    
    PRINT 'Email sent successfully.';
END TRY
BEGIN CATCH
    PRINT 'Error sending email:';
    PRINT ERROR_MESSAGE();
END CATCH;
