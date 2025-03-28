DECLARE @SearchTerm VARCHAR(100)
SET @SearchTerm = '800433'

DECLARE @TableName NVARCHAR(128)
DECLARE @ColumnName NVARCHAR(128)
DECLARE @SearchQuery NVARCHAR(1000)

CREATE TABLE #SearchResults (TableName NVARCHAR(128), ColumnName NVARCHAR(128))

DECLARE tables_cursor CURSOR FOR
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'

OPEN tables_cursor
FETCH NEXT FROM tables_cursor INTO @TableName

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE columns_cursor CURSOR FOR
    SELECT COLUMN_NAME
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = @TableName

    OPEN columns_cursor
    FETCH NEXT FROM columns_cursor INTO @ColumnName

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @SearchQuery = 'IF EXISTS (SELECT * FROM ' + @TableName + ' WHERE ' + @ColumnName + ' LIKE ''%' + @SearchTerm + '%'') INSERT INTO #SearchResults VALUES (''' + @TableName + ''', ''' + @ColumnName + ''')'

        EXEC sp_executesql @SearchQuery

        FETCH NEXT FROM columns_cursor INTO @ColumnName
    END

    CLOSE columns_cursor
    DEALLOCATE columns_cursor

    FETCH NEXT FROM tables_cursor INTO @TableName
END

CLOSE tables_cursor
DEALLOCATE tables_cursor

SELECT * FROM #SearchResults

----DROP TABLE #SearchResults
