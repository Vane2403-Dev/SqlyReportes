USE [Emova_ERP]
GO
/****** Object:  StoredProcedure [dbo].[GenerarInsert_fromObject]    Script Date: 4/2/2025 16:48:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO





-- EXEC GenerarInsert_fromObject @ViewTableName = 'TipoArchivosAdjuntos', @where = 'TipoArchivoId > 0'
-- EXEC GenerarInsert_fromObject @ViewTableName = 'GRLCprteOperacionUsuario', @where = "OperTipo = 330010", @debugString = 1
-- EXEC GenerarInsert_fromObject @ViewTableName = 'DOCCruce', @where = 'CprteTipo = "RC"', @debugString = 1
ALTER           PROCEDURE [dbo].[GenerarInsert_fromObject](
	@ViewTableName varchar(200) = NULL
	, @where varchar(max) = NULL
	, @orderBy varchar(max) = NULL
	, @execSelect bit = 0
	, @debugString bit = 0
	, @insertIntoTemp varchar(200) = NULL
	, @dataBaseName varchar(200) = NULL
	, @checkIfExists bit = 1
)
AS

BEGIN

	SET NOCOUNT ON

	DECLARE @SQLString nvarchar(MAX) = ''
	DECLARE @salto char(1) = char(10)
	DECLARE @TAB char(1) = char(9)
	DECLARE @SQLStringColumns nvarchar(max)
	DECLARE @SQLStringViewTableNameAdds nvarchar(max)
	DECLARE @SQLStringValuesAlls nvarchar(max)
	DECLARE @SQLStringWhereKeys nvarchar(max)
	DECLARE @SQLStringJoinKeys nvarchar(max)
	DECLARE @SQLStringWhere nvarchar(max)
	DECLARE @SQLStringParamsIdentity varchar(1000) = ''
	DECLARE @TableHasIdentity int = OBJECTPROPERTY(OBJECT_ID(@ViewTableName), 'TableHasIdentity')
	DECLARE @SQLStringParams nvarchar(max)
	DECLARE @lIndix bit = 0

	SET @SQLStringParams	 = @TAB+' '
	SET @SQLStringViewTableNameAdds = ' T0 '
	SET @SQLStringValuesAlls = ' '
	SET @SQLStringWhereKeys  = @TAB
	SET @SQLStringJoinKeys  = @TAB
	SET @SQLStringWhere		 = @TAB

	SET @SQLStringColumns = ' '
	SELECT 
	@SQLStringColumns = @SQLStringColumns + CASE WHEN (C.is_nullable = 0) THEN 'T0.' ELSE '' END + '' + c.name 
	+ ',' 
	,

	@SQLStringValuesAlls = @SQLStringValuesAlls + '@' + c.name + ' ' 
	+ ',' 
	FROM sys.columns C
	INNER JOIN sys.objects O 
	ON O.object_id = C.object_id
	INNER JOIN sys.types T
	ON T.user_type_id = C.user_type_id
	WHERE O.name = @ViewTableName 
	AND O.type IN ('U','V')


	SELECT
	@SQLStringWhereKeys = @SQLStringWhereKeys + '(' + c.name + 
	+ CASE	
		WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN ' = ' + '@' + c.name + '' /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
		WHEN C.user_type_id IN (43,48,52,56,104,127,128,189)	THEN ' = ' + '@' + c.name + ''/*enteros: datetimeoffset,tinyint,smallint,int,bit,bigint,hierarchyid,timestamp,*/	
		WHEN C.user_type_id IN (40,42,58,61) THEN ' = ' + '@' + c.name + '' /*fechas: date,datetime2,smalldatetime,datetime,*/	
		WHEN C.user_type_id IN (59,60,62,106,108,122)THEN ' = ' + '@' + c.name + '' /*numericos: real,money,float,decimal,numeric,smallmoney,*/	
		WHEN C.user_type_id IN (34,35,98,99,129,130,165,173,257,258,259)THEN ' = ' + '@' + c.name + '' /*otros: image,text,sql_variant,ntext,geometry,geography,varbinary,binary,Hierarchy,TXT_RegimenIIBBBSASPerc,TXT_RegimenIIBBBSASRet,*/
	ELSE ' = ' + '@' + c.name + ''  END 
	+ ')'
	+ @salto + @TAB + @TAB + @TAB + 'AND ' 
	,
	@lIndix = 1
	,
	@SQLStringJoinKeys = @SQLStringJoinKeys + '(T0.' + c.name + 
	+ CASE	
		WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN ' = ' + 'T1.' + c.name + '' /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
		WHEN C.user_type_id IN (43,48,52,56,104,127,128,189)	THEN ' = ' + 'T1.' + c.name + ''/*enteros: datetimeoffset,tinyint,smallint,int,bit,bigint,hierarchyid,timestamp,*/	
		WHEN C.user_type_id IN (40,42,58,61) THEN ' = ' + 'T1.' + c.name + '' /*fechas: date,datetime2,smalldatetime,datetime,*/	
		WHEN C.user_type_id IN (59,60,62,106,108,122)THEN ' = ' + 'T1.' + c.name + '' /*numericos: real,money,float,decimal,numeric,smallmoney,*/	
		WHEN C.user_type_id IN (34,35,98,99,129,130,165,173,257,258,259)THEN ' = ' + 'T1.' + c.name + '' /*otros: image,text,sql_variant,ntext,geometry,geography,varbinary,binary,Hierarchy,TXT_RegimenIIBBBSASPerc,TXT_RegimenIIBBBSASRet,*/
	ELSE ' = ' + 'T1.' + c.name + ''  END 
	+ ')'
	+ @salto + @TAB + @TAB + @TAB + 'AND ' 
	
	--c.* 
	FROM sys.columns C
	INNER JOIN sys.objects O 
	ON O.object_id = C.object_id
	INNER JOIN sys.types T
	ON T.user_type_id = C.user_type_id
					INNER JOIN sys.indexes AS i 
					ON O.object_id = i.object_id
					AND is_primary_key = 1
					INNER JOIN sys.index_columns AS ic   
					ON i.object_id = ic.object_id 
					AND i.index_id = ic.index_id  
					AND ic.column_id = C.column_id
					AND COL_NAME(ic.object_id,ic.column_id) = c.name
					WHERE O.name = @ViewTableName 
					AND O.type IN ('U','V')

	SELECT
	@SQLStringWhere = @SQLStringWhere + '(' + CASE WHEN (C.is_nullable = 0) THEN 'T0.' ELSE '' END + '' + c.name + 
	+ CASE	
		WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN ' LIKE ''%''+LTRIM(RTRIM(' + '@' + c.name + '))+''%''' /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
		WHEN C.user_type_id IN (43,48,52,56,104,127,128,189)	THEN ' = ' + '@' + c.name + ''/*enteros: datetimeoffset,tinyint,smallint,int,bit,bigint,hierarchyid,timestamp,*/	
		WHEN C.user_type_id IN (40,42,58,61) THEN ' = ' + '@' + c.name + '' /*fechas: date,datetime2,smalldatetime,datetime,*/	
		WHEN C.user_type_id IN (59,60,62,106,108,122)THEN ' = ' + '@' + c.name + '' /*numericos: real,money,float,decimal,numeric,smallmoney,*/	
		WHEN C.user_type_id IN (34,35,98,99,129,130,165,173,257,258,259)THEN ' = ' + '@' + c.name + '' /*otros: image,text,sql_variant,ntext,geometry,geography,varbinary,binary,Hierarchy,TXT_RegimenIIBBBSASPerc,TXT_RegimenIIBBBSASRet,*/
	ELSE ' = ' + '@' + c.name + ''  END 
	+ ' OR @' + c.name + ' IS NULL)'
	+ @salto + @TAB + @TAB + @TAB + 'AND ' 
		
	--c.* 
	FROM sys.columns C
	INNER JOIN sys.objects O 
	ON O.object_id = C.object_id
	INNER JOIN sys.types T
	ON T.user_type_id = C.user_type_id
	WHERE O.name = @ViewTableName 
	AND O.type IN ('U','V')

			SET @SQLStringValuesAlls = LEFT(@SQLStringValuesAlls , LEN(@SQLStringValuesAlls )-CASE WHEN LEN(@SQLStringValuesAlls) >= 1 THEN 1 ELSE 0 END)
			DECLARE @insertINTOViewTablaName varchar(500) = @SQLStringValuesAlls

				SET @SQLStringValuesAlls  = ''
				SET @SQLStringParams = ''
											
				SELECT 
				@SQLStringParams = @SQLStringParams + @salto + @TAB+@TAB+@TAB+@TAB+'+'+
				CASE WHEN @TableHasIdentity = 1 AND C.is_identity = 1 THEN 'CASE WHEN @TableHasIdentity = 1 THEN ' ELSE '' END + 
				'ISNULL(' +
				+ CASE	
				--WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN " CASE WHEN CHARINDEX('''',"+c.name+")>0 THEN '''' ELSE '''' END +" /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
				WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN "''''+" /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
				WHEN C.user_type_id IN (43,48,52,56,104,127,128,189)	THEN ""/*enteros: datetimeoffset,tinyint,smallint,int,bit,bigint,hierarchyid,timestamp,*/	
				WHEN C.user_type_id IN (40,42,58,61) THEN "''''+" /*fechas: date,datetime2,smalldatetime,datetime,*/	
				WHEN C.user_type_id IN (59,60,62,106,108,122)THEN "" /*numericos: real,money,float,decimal,numeric,smallmoney,*/	
				WHEN C.user_type_id IN (34,35,98,99,129,130,165,173,257,258,259)THEN "''''+" /*otros: image,text,sql_variant,ntext,geometry,geography,varbinary,binary,Hierarchy,TXT_RegimenIIBBBSASPerc,TXT_RegimenIIBBBSASRet,*/
				ELSE "''''+" END +
				
				+ CASE	
				WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN 'LTRIM(RTRIM(REPLACE(' /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
				WHEN C.user_type_id IN (43,48,52,56,104,127,128,189)	THEN 'CONVERT('+'VARCHAR(100),('/*enteros: datetimeoffset,tinyint,smallint,int,bit,bigint,hierarchyid,timestamp,*/	
				WHEN C.user_type_id IN (40,42,58,61) THEN 'CONVERT('+'VARCHAR(30),(' /*fechas: date,datetime2,smalldatetime,datetime,*/	
				WHEN C.user_type_id IN (59,60,62,106,108,122)THEN 'CONVERT('+'VARCHAR(100),(' /*numericos: real,money,float,decimal,numeric,smallmoney,*/	
				WHEN C.user_type_id IN (34,35,98,99,129,130,165,173,257,258,259)THEN 'CONVERT('+'VARCHAR(100),(' /*otros: image,text,sql_variant,ntext,geometry,geography,varbinary,binary,Hierarchy,TXT_RegimenIIBBBSASPerc,TXT_RegimenIIBBBSASRet,*/
				ELSE 'CONVERT('+'VARCHAR(100),(' END +
				''   + c.name + ''+CASE	
				WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN ','''''''',''''''+CHAR(39)+'''''')))' /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
				WHEN C.user_type_id IN (40,42,58,61) THEN '),112)' /*fechas: date,datetime2,smalldatetime,datetime,*/	
				ELSE '))' END +''
				+ CASE	
				--WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN "+ CASE WHEN CHARINDEX('''',"+c.name+")>0 THEN '''' ELSE '''' END " /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
				WHEN C.user_type_id IN (36,41,167,175,231,239,241,256)	THEN "+''''" /*caracteres: uniqueidentifier,time,varchar,char,nvarchar,nchar,xml,sysname,*/	
				WHEN C.user_type_id IN (43,48,52,56,104,127,128,189)	THEN ""/*enteros: datetimeoffset,tinyint,smallint,int,bit,bigint,hierarchyid,timestamp,*/	
				WHEN C.user_type_id IN (40,42,58,61) THEN "+''''" /*fechas: date,datetime2,smalldatetime,datetime,*/	
				WHEN C.user_type_id IN (59,60,62,106,108,122)THEN "" /*numericos: real,money,float,decimal,numeric,smallmoney,*/	
				WHEN C.user_type_id IN (34,35,98,99,129,130,165,173,257,258,259)THEN "+''''" /*otros: image,text,sql_variant,ntext,geometry,geography,varbinary,binary,Hierarchy,TXT_RegimenIIBBBSASPerc,TXT_RegimenIIBBBSASRet,*/
				ELSE "+''''" END  + 
				",'NULL')+','"+
				CASE WHEN @TableHasIdentity = 1 AND C.is_identity = 1 THEN ' ELSE '''' END' ELSE '' END
				,
				@SQLStringValuesAlls = @SQLStringValuesAlls + '' + c.name + ','
				,
				@SQLStringParamsIdentity = @SQLStringParamsIdentity + '' + CASE WHEN @TableHasIdentity = 1 AND C.is_identity = 1 THEN c.name + ',' ELSE '' END
			FROM sys.columns C
			INNER JOIN sys.objects O 
			ON O.object_id = C.object_id
			INNER JOIN sys.types T
			ON T.user_type_id = C.user_type_id
			WHERE O.name = @ViewTableName 
			AND O.type IN ('U','V')

			SET @SQLStringJoinKeys = LEFT(@SQLStringJoinKeys , LEN(@SQLStringJoinKeys)-CASE WHEN LEN(@SQLStringJoinKeys) >= 3 THEN 3 ELSE 0 END)+""
			SET @SQLStringParams = LEFT(@SQLStringParams , LEN(@SQLStringParams )-CASE WHEN LEN(@SQLStringParams) >= 3 THEN 3 ELSE 0 END)+"'),'"
			SET @SQLStringValuesAlls = LEFT(@SQLStringValuesAlls , LEN(@SQLStringValuesAlls )-CASE WHEN LEN(@SQLStringValuesAlls) >= 1 THEN 1 ELSE 0 END)


	DECLARE @SQLStringColumnsScript varchar(max) = REPLACE(REPLACE(LEFT(@SQLStringColumns, LEN(@SQLStringColumns)-CASE WHEN LEN(@SQLStringColumns) >= 1 THEN 1 ELSE 0 END),'GD.','T0.'),'TaB.','T0.')
	DECLARE @SQLStringFirstColumn varchar(100) = CASE WHEN CHARINDEX(',',@SQLStringColumnsScript) > 1 THEN LEFT(@SQLStringColumnsScript,CHARINDEX(',',@SQLStringColumnsScript)-1) ELSE @SQLStringColumnsScript END

	IF @lIndix = 0 SET @checkIfExists = 0

			SET @SQLString = 
				@TAB+@TAB+@TAB+'SELECT '+ 
				@SQLStringColumnsScript+
				' INTO #'+@ViewTableName+@salto+
				@TAB+@TAB+@TAB+'FROM '+ISNULL(@dataBaseName+'.','')+'dbo.'+@ViewTableName+@SQLStringViewTableNameAdds+@salto+
				'WHERE 1 = 2'+@salto+''

			SET @SQLString = @SQLString + 
			'
			IF OBJECTPROPERTY(OBJECT_ID('''+@ViewTableName+'''), ''TableHasIdentity'') = 1
				SET IDENTITY_INSERT #'+@ViewTableName+' ON

'+@salto+
				@TAB+@TAB+@TAB+@TAB+'INSERT INTO #'+@ViewTableName+"("+@salto+REPLACE(@SQLStringValuesAlls,'@','')+")"+@salto+
				@TAB+@TAB+@TAB+@TAB+'SELECT ' + 
				@SQLStringColumnsScript+
				' FROM '+ISNULL(@dataBaseName+'.','')+'dbo.'+@ViewTableName+@SQLStringViewTableNameAdds+@salto+''

IF NOT @where IS NULL AND @where != ''
	SET @SQLString = @SQLString + 
				'WHERE '+@where + @salto


			SET @SQLString = @SQLString + 
'
			IF OBJECTPROPERTY(OBJECT_ID('''+@ViewTableName+'''), ''TableHasIdentity'') = 1
				SET IDENTITY_INSERT #'+@ViewTableName+' OFF'
IF @execSelect = 1
			SET @SQLString = @SQLString + 
'
SELECT * FROM #'+@ViewTableName+'
'
			SET @SQLString = @SQLString + 
'

			DECLARE @tablaResultados TABLE (id int identity, linea varchar(max))
			DECLARE @strDateForName varchar(29) = REPLACE(REPLACE(REPLACE(REPLACE(convert(varchar(29), getdate(),121),'':'',''''),'' '',''''),''.'',''''),''-'','''')
			DECLARE @TableHasIdentity int = OBJECTPROPERTY(OBJECT_ID('''+@ViewTableName+'''), ''TableHasIdentity'')
			DECLARE @fieldList varchar(max) = '''+REPLACE(REPLACE(@insertINTOViewTablaName,'@',''),@SQLStringParamsIdentity,'')+'''
			-- SET @TableHasIdentity = 0 -- desconmentar si no se quiere distribuir con el campo IDENTITY
			IF @TableHasIdentity = 1
				SET @fieldList = '''+'''+@fieldList


			INSERT INTO @tablaResultados VALUES (''-- Insert_fromObject('+ @ViewTableName+')'')
			INSERT INTO @tablaResultados VALUES (''-- SCRIPT para INSERTAR datos en tabla '
			-- @SQLStringParamsIdentity+
			SET @SQLString = @SQLString + @ViewTableName+''')'+
'
			INSERT INTO @tablaResultados VALUES (''-- RESULTADO de la ejecución del SP: EXEC GenerarInsert_fromObject @ViewTableName = '''
			SET @SQLString = @SQLString + ''''+@ViewTableName+''''''
			SET @SQLString = @SQLString + ISNULL(', @where = '''''+@where+'''''''','''')+')'
SET @SQLString = @SQLString + 
'
			INSERT INTO @tablaResultados VALUES (''-------'' + CONVERT(VARCHAR(30),getdate()))
			INSERT INTO @tablaResultados VALUES (''-- Previo a ejecutar este script realizar los siguientes pasos:'')
			INSERT INTO @tablaResultados VALUES (''-- 1. Seleccionar la base de destino'')
			INSERT INTO @tablaResultados VALUES (''-- 2. Verificar si existe la tabla "'+@ViewTableName+'" y de no existir proceder a crearla con su correspondiente script'')
			INSERT INTO @tablaResultados VALUES (''-- 3. Proceder a ejecutar este script'')
			INSERT INTO @tablaResultados VALUES ('''')
			IF (SELECT COUNT(*) FROM #'+@ViewTableName+' ) > 0 BEGIN
			INSERT INTO @tablaResultados VALUES (''BEGIN TRANSACTION trans'+LEFT(@ViewTableName,27)+''')
			INSERT INTO @tablaResultados VALUES ('''')
			INSERT INTO @tablaResultados VALUES (''IF EXISTS (SELECT * FROM sys.objects WHERE object_id = (OBJECT_ID(N''''bkp_''+@strDateForName+''_'+@ViewTableName+''''')) AND type in (N''''U'''')) '')
			INSERT INTO @tablaResultados VALUES (''	DROP TABLE bkp_''+@strDateForName+''_'+@ViewTableName+''')
			INSERT INTO @tablaResultados VALUES (''GO'')
			INSERT INTO @tablaResultados VALUES (''SELECT * INTO bkp_''+@strDateForName+''_'+@ViewTableName+' FROM '+@ViewTableName+''')
			INSERT INTO @tablaResultados VALUES ('''')
			INSERT INTO @tablaResultados VALUES (''ALTER TABLE '+@ViewTableName+' NOCHECK CONSTRAINT ALL'')
			INSERT INTO @tablaResultados VALUES (''ALTER TABLE '+@ViewTableName+' DISABLE TRIGGER ALL'')
			INSERT INTO @tablaResultados VALUES ('''')
			INSERT INTO @tablaResultados VALUES (''-- TRUNCATE TABLE '+@ViewTableName+''')
			INSERT INTO @tablaResultados VALUES ('''')
			INSERT INTO @tablaResultados VALUES (''SET QUOTED_IDENTIFIER OFF'')
			INSERT INTO @tablaResultados VALUES (''GO'')
			INSERT INTO @tablaResultados VALUES ('''')
			INSERT INTO @tablaResultados VALUES (''-- Se insertarán ''+CONVERT(varchar(10),(SELECT COUNT(*) FROM #'+@ViewTableName+'))+'' registros'')
			INSERT INTO @tablaResultados VALUES ('''')
'
IF @checkIfExists = 1 BEGIN
			SET @SQLString = @SQLString + 
'			
			INSERT INTO @tablaResultados VALUES (''If NOT OBJECT_ID(''''tempdb..#'+@ViewTableName+''''') IS NULL DROP TABLE #'+@ViewTableName+''')
			INSERT INTO @tablaResultados VALUES (''SELECT '+@SQLStringColumnsScript+@salto+
				'INTO #'+@ViewTableName+@salto+
				+'FROM '+@ViewTableName+@SQLStringViewTableNameAdds+@salto+
				'WHERE 1 = 2'+@salto+''
			+''')


'	
END
			SET @SQLString = @SQLString + 
'			
			IF @TableHasIdentity = 1
			INSERT INTO @tablaResultados VALUES (''SET IDENTITY_INSERT '+CASE WHEN @checkIfExists = 1 THEN '#' ELSE '' END +@ViewTableName+' ON '')


			 
			INSERT INTO @tablaResultados VALUES (''INSERT INTO '+CASE WHEN @checkIfExists = 1 THEN '#' ELSE '' END +@ViewTableName+'('+@salto+'''+@fieldList+'') VALUES'')

			DECLARE @IdTop int = (SELECT COUNT(*) FROM @tablaResultados)
			'

			SET @SQLString = @SQLString + 
'
			INSERT INTO @tablaResultados 
			SELECT SPACE(6)+REPLACE(REPLACE(REPLACE(''('''+
REPLACE(' '+@SQLStringParams+' ','TaB.','T0.')+",',NUL)',',NULL)'),',NUL,',',NULL,'),'(NUL,','(NULL,')"+@salto+
'			FROM #'+@ViewTableName+' T0'+@salto+
			ISNULL(@orderBy,'')+ '

			DECLARE @maxid int = @@identity, @corteLinea int = 500
			If @maxid > @corteLinea
				UPDATE t SET linea = 
					REPLACE(linea,''),'','')''+char(10)+char(10)+char(10)+''INSERT INTO '+CASE WHEN @checkIfExists = 1 THEN '#' ELSE '' END +@ViewTableName+'(''+@fieldList+'') VALUES'')
				FROM @tablaResultados t WHERE (id-@IdTop)%@corteLinea = 0 AND id <> @maxid AND id > @IdTop

			INSERT INTO @tablaResultados VALUES ('''')
			 

			IF @TableHasIdentity = 1
			INSERT INTO @tablaResultados VALUES (''SET IDENTITY_INSERT '+CASE WHEN @checkIfExists = 1 THEN '#' ELSE '' END +@ViewTableName+' OFF '')

'
IF @checkIfExists = 1 BEGIN
			SET @SQLString = @SQLString + 
'			
			IF @TableHasIdentity = 1
			INSERT INTO @tablaResultados VALUES (''SET IDENTITY_INSERT '+@ViewTableName+' ON '')

			INSERT INTO @tablaResultados VALUES (''INSERT INTO '+@ViewTableName+'(' +
				REPLACE(@SQLStringColumnsScript,'T0.','')+')
			SELECT '+REPLACE(REPLACE(@SQLStringColumnsScript,',',',T0.'),'T0.T0.','T0.')+'
			FROM #'+@ViewTableName+' T0
			LEFT OUTER JOIN '+@ViewTableName+' T1
			ON '+@SQLStringJoinKeys+'
			WHERE '+REPLACE(@SQLStringFirstColumn,'T0.','T1.')+' IS NULL
			'')

			IF @TableHasIdentity = 1
			INSERT INTO @tablaResultados VALUES (''SET IDENTITY_INSERT '+@ViewTableName+' OFF '')
'
END
			SET @SQLString = @SQLString + 
'			
			INSERT INTO @tablaResultados VALUES (''ALTER TABLE '+@ViewTableName+' ENABLE TRIGGER ALL'')
			INSERT INTO @tablaResultados VALUES (''ALTER TABLE '+@ViewTableName+' CHECK CONSTRAINT ALL'')
			INSERT INTO @tablaResultados VALUES ('''')
			INSERT INTO @tablaResultados VALUES ('''')
			INSERT INTO @tablaResultados VALUES (''COMMIT TRANSACTION trans'+LEFT(@ViewTableName,27)+''')
			INSERT INTO @tablaResultados VALUES (''GO'')
			INSERT INTO @tablaResultados VALUES ('''')
			END ELSE BEGIN
			INSERT INTO @tablaResultados VALUES ('''')
			INSERT INTO @tablaResultados VALUES (''-- ATENCION! La tabla '+@ViewTableName+' no tiene registros'')
			END
			'+ISNULL('INSERT INTO '+@insertIntoTemp,'')+'
			SELECT CASE WHEN len(linea) > CASE WHEN id = @maxid THEN 1 ELSE 0 END THEN REPLACE(LEFT(linea, len(linea) - CASE WHEN id = @maxid THEN 1 ELSE 0 END ),'',NUL,'','',NULL,'') ELSE linea END AS [-- Script Resultado] FROM @tablaResultados ORDER BY id
'+@salto+
'			DROP TABLE #'+@ViewTableName+''+@salto

				SET @SQLString = @SQLString + 
						''

	IF @debugString = 1 SELECT @SQLString

	EXEC (@SQLString)

END

RETURN

