SELECT 
    OBJECT_NAME(object_id) AS ProcedureName, 
    definition AS ProcedureDefinition
FROM 
    sys.sql_modules
WHERE 
    definition LIKE '%usrsispen15%'
    AND OBJECTPROPERTY(object_id, 'IsProcedure') = 1;


	SELECT 
    OBJECT_NAME(object_id) AS ProcedureName, 
    definition AS ProcedureDefinition
FROM 
    sys.sql_modules
WHERE 
    definition LIKE '%spDTSMovimientosContablesPendientes%' 
	AND definition LIKE '%CPG%'
    AND OBJECTPROPERTY(object_id, 'IsProcedure') = 1;
