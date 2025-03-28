SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [IVACOMPRAS_CON_CTACONTABLE] 30000000, '20250101', '20250131' 

-- Procedimiento almacenado para obtener compras IVA con cuenta contable y análisis
CREATE OR ALTER  PROCEDURE [dbo].[IVACOMPRAS_CON_CTACONTABLE]
(
   @SOCId INT,
   @FecDes DATETIME,
   @FecHas DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;
	
	SELECT *
INTO #Temp1
from 
(
SELECT impl.*, 
 rc.nroasiento, DC.cuecontableid, dc.anacontableid, dc.cidnumero, (dc.detdebe - dc.dethaber) AS importeContable
FROM IMPLibro impl
LEFT OUTER JOIN DOCDetImpCon ic
    ON ic.empid = impl.empid
    AND ic.uopid = impl.uopid
    AND ic.docnrointdoc = impl.numerointdoc
LEFT OUTER JOIN CAPMCCabecera MCC
    ON MCC.SOCId = IC.EmpId
    AND MCC.UopId = IC.UopId
    AND MCC.NroAsiento = IC.NroAsiento
LEFT OUTER JOIN CON_CabeceraRCE RCE
    ON RCE.SOCId = MCC.SOCId
    AND RCE.UopId = MCC.UopId
    AND RCE.NroAsiento = MCC.NroAsientoRCE
LEFT OUTER JOIN CON_CabeceraRC RC
    ON RC.SOCId = MCC.SOCId
    AND RC.UopId = MCC.UopId
    AND RC.NroAsientoRCE = MCC.NroAsientoRCE
LEFT OUTER JOIN CON_detalleRC DC
    ON RC.SOCId = DC.SOCId
    AND RC.UopId = DC.UopId
    AND RC.NroAsiento = DC.NroAsiento
WHERE impl.EMPId =  @socid
    AND impl.IMPTipoId = 'IVAC'
    AND FechaContable BETWEEN @FecDes AND  @FecHas 
	AND impl.NumeroDocumento < 50000000000
    AND impl.sistema = 'CTAPAG'
  AND (DC.codtipana NOT IN ('ICF', 'INA', 'IRE','BAN', 'FONF', 'FONR', 'IPR ', 'ITM' ) or dc.CodTipAna is null)
	and (DC.CueContableId NOT IN ('21101') or DC.CueContableId is null)

union

SELECT impl.*,
 rc.nroasiento, DC.cuecontableid, dc.anacontableid, dc.cidnumero, (dc.detdebe - dc.dethaber) AS importeContable
FROM IMPLibro impl
LEFT OUTER JOIN CON_RelSisOriRC WR
on WR.socid = impl.empid
and WR.uopid = impl.UOpId
and WR.nrodocori = impl.IMPORNumero
AND WR.sisdocori = 'BANCOS'
LEFT OUTER JOIN CON_CabeceraRC RC
    ON RC.SOCId = WR.SOCId
    AND RC.UopId = WR.UopId
    AND RC.NroAsiento = WR.NroAsiento
LEFT OUTER JOIN CON_detalleRC DC
    ON RC.SOCId = DC.SOCId
    AND RC.UopId = DC.UopId
    AND RC.NroAsiento = DC.NroAsiento
	AND WR.itmid = DC.ItmId
WHERE impl.EMPId = @socid
    AND impl.IMPTipoId = 'IVAC'
     AND FechaContable BETWEEN @FecDes AND  @FecHas 
	AND impl.NumeroDocumento < 50000000000
    AND impl.sistema = 'BANCOS'
  AND (DC.codtipana NOT IN ('ICF', 'INA', 'IRE','BAN', 'FONF', 'FONR', 'IPR ', 'ITM' ) or dc.CodTipAna is null)


Union


SELECT impl.*,
 rc.nroasiento, DC.cuecontableid, dc.anacontableid, dc.cidnumero, (dc.detdebe - dc.dethaber) AS importeContable
FROM IMPLibro impl
LEFT OUTER JOIN FONDetMovimiento  FM
    ON FM.SOCId = impl.empid
    AND FM.uopid = impl.uopid
    AND FM.docnrointdoc = impl.numerointdoc
LEFT OUTER JOIN CAPMCCabecera MCC
    ON MCC.SOCId = FM.SOCId
    AND MCC.UopId = FM.UopId
    AND MCC.NroAsiento = FM.NroAsiento
LEFT OUTER JOIN CON_CabeceraRCE RCE
    ON RCE.SOCId = MCC.SOCId
    AND RCE.UopId = MCC.UopId
    AND RCE.NroAsiento = MCC.NroAsientoRCE
LEFT OUTER JOIN CON_CabeceraRC RC
    ON RC.SOCId = MCC.SOCId
    AND RC.UopId = MCC.UopId
    AND RC.NroAsientoRCE = MCC.NroAsientoRCE
LEFT OUTER JOIN CON_detalleRC DC
    ON RC.SOCId = DC.SOCId
    AND RC.UopId = DC.UopId
    AND RC.NroAsiento = DC.NroAsiento
WHERE impl.EMPId =  @socid
    AND impl.IMPTipoId = 'IVAC'
	    AND FechaContable BETWEEN @FecDes AND  @FecHas 
	AND impl.NumeroDocumento < 50000000000
    AND impl.sistema = 'FONDOS'
	AND (DC.codtipana NOT IN ('ICF', 'INA', 'IRE','BAN', 'FONF', 'FONR', 'IPR ', 'ITM' ) or dc.CodTipAna is null)
	) as T

	-- Unir tabla con nombres de  campos 
SELECT t1.*, cn.CueConDes FROM #Temp1 t1
LEFT JOIN CON_CabCueDef CN
ON T1.EMPID = CN.SOCID
AND T1.UOPID = CN.UOPID
AND T1.CueContableId = CN.CueContableId



	
	-- Eliminar tablas temporales
DROP TABLE #Temp1;
	
	end
	go
