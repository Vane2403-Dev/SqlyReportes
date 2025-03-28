SELECT 
    o.name AS ProcedureName,
    o.modify_date AS LastModifiedDate
FROM 
    sys.objects o
INNER JOIN 
    sys.sql_modules m
ON 
    o.object_id = m.object_id
WHERE 
    o.type = 'P'  -- 'P' indica que el objeto es un procedimiento almacenado
AND 
    o.name = 'CONspSaldoCuentasBSSConso';
