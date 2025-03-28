SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--exec [IVACOMPRAS_CON_CTACONTABLE_Control] 30000000, '20250101', '20250131' 

-- Procedimiento almacenado para obtener compras IVA con cuenta contable y análisis
CREATE OR ALTER PROCEDURE [dbo].[IVACOMPRAS_CON_CTACONTABLE_Control]
(
   @SOCId INT,
   @FecDes DATETIME,
   @FecHas DATETIME
)
AS
BEGIN
    SET NOCOUNT ON;

-- Crear tabla temporal para la primera consulta


	SELECT *
INTO #Temp1
FROM
(
---CTASAPAGAR 1 ---
SELECT impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
       impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
       impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
       impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
       impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
       impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
       impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
       impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
       impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
       impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI,
       rc.nroasiento, 
       SUM(dc.detdebe - dc.dethaber) AS importeGastoActivo
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
	GROUP BY impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
         impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
         impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
         impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
         impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
         impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
         impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
         impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
         impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
         impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI, rc.nroasiento
union
 
 --- BANCOS 1---
SELECT impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
       impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
       impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
       impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
       impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
       impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
       impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
       impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
       impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
       impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI,
       rc.nroasiento, 
       SUM(dc.detdebe - dc.dethaber) AS importeGastoActivo
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
  GROUP BY impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
         impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
         impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
         impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
         impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
         impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
         impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
         impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
         impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
         impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI, rc.nroasiento

Union

---FONDOS 1---
SELECT impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
       impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
       impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
       impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
       impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
       impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
       impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
       impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
       impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
       impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI,
       rc.nroasiento, 
       SUM(dc.detdebe - dc.dethaber) AS importeGastoActivo
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
	GROUP BY impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
         impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
         impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
         impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
         impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
         impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
         impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
         impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
         impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
         impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI, rc.nroasiento
		 ) as T1
		

	-- Crear tabla temporal para la segunda consulta

		SELECT *
INTO #Temp2
FROM
(
	

	---CUENTAS A PAGAR 2---
SELECT impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
       impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
       impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
       impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
       impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
       impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
       impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
       impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
       impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
       impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI,
       rc.nroasiento,  
       SUM(dc.detdebe - dc.dethaber) AS importeImpuestos
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
WHERE impl.EMPId = @socid
    AND impl.IMPTipoId = 'IVAC'
    AND FechaContable BETWEEN @FecDes AND @FecHas 
    AND impl.NumeroDocumento < 50000000000
    AND impl.sistema = 'CTAPAG'
    AND (DC.codtipana IN ( 'ICF','INA', 'IRE', 'IPR ', 'ITM' ) or dc.CodTipAna is null)
    AND (DC.codtipana NOT IN ('BAN', 'FONF', 'FONR') or dc.CodTipAna is null)
    AND (DC.CueContableId NOT IN ('21101') or DC.CueContableId is null)
GROUP BY impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
         impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
         impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
         impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
         impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
         impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
         impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
         impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
         impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
         impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI, rc.nroasiento
		 
		 union

---BANCOS 2---
 SELECT impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
       impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
       impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
       impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
       impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
       impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
       impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
       impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
       impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
       impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI,
       rc.nroasiento, 
       SUM(dc.detdebe - dc.dethaber) AS importeImpuestos
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
     AND (DC.codtipana IN ( 'ICF','INA', 'IRE', 'IPR ', 'ITM' ) or dc.CodTipAna is null)
    AND (DC.codtipana NOT IN ('BAN', 'FONF', 'FONR') or dc.CodTipAna is null)
  GROUP BY impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
         impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
         impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
         impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
         impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
         impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
         impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
         impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
         impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
         impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI, rc.nroasiento

Union
--- FONDOS 2---

SELECT impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
       impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
       impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
       impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
       impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
       impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
       impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
       impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
       impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
       impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI,
       rc.nroasiento, 
       SUM(dc.detdebe - dc.dethaber) AS importeImpuestos
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
  AND (DC.codtipana IN ( 'ICF','INA', 'IRE', 'IPR ', 'ITM' ) or dc.CodTipAna is null)
    AND (DC.codtipana NOT IN ('BAN', 'FONF', 'FONR') or dc.CodTipAna is null)
	GROUP BY impl.EMPId, impl.IMPORNumero, impl.NumeroIntDoc, impl.IMPTipoId, impl.SucursalDGI, 
         impl.Periodo, impl.UOpId, impl.FechaComprobante, impl.FechaContable, impl.TipoComprobante, 
         impl.LetraComprobante, impl.NumeroComprobante, impl.TipoDocNemo, impl.NombreVendedor, 
         impl.TipoDocumento, impl.NumeroDocumento, impl.IMPTCuId, impl.PosicionFrenteImp, 
         impl.Regimen, impl.TotalOperacion, impl.NoGravado, impl.Gravado1, impl.Gravado2, 
         impl.Alicuota, impl.ImpuestoLiq1, impl.ImpuestoLiq2, impl.ImpuestoLiqAcrec, 
         impl.OperacionesExcentas, impl.Otras, impl.IvaRniMonotrib, impl.Col1, impl.Col2, impl.Col3, 
         impl.Col4, impl.Col5, impl.Col6, impl.Col7, impl.Col8, impl.Col9, impl.CodigoMoneda, 
         impl.TipoCambio, impl.Sistema, impl.CantidadHojas, impl.CodigoAduana, impl.AnoDespacho, 
         impl.NumeroDespacho, impl.FechaDespacho, impl.DOCNroCAI, rc.nroasiento
		 ) as T2
	
	/*
-- Unir ambas tablas temporales
SELECT t1.*, t2.importeImpuestos , (t1.TotalOperacion -T1.importeGastoActivo-t2.importeImpuestos) As Control
FROM #Temp1 t1
LEFT JOIN #Temp2 t2
    ON t1.EMPId = t2.EMPId
    AND t1.IMPORNumero = t2.IMPORNumero
    AND t1.NumeroIntDoc = t2.NumeroIntDoc
    AND t1.IMPTipoId = t2.IMPTipoId
    AND t1.FechaComprobante = t2.FechaComprobante
    AND t1.nroasiento = t2.nroasiento
ORDER BY t1.nroasiento;*/

SELECT 
    t1.*, 
    ISNULL(t2.importeImpuestos, 0) AS importeImpuestos, 
    (ISNULL(t1.TotalOperacion, 0) - ISNULL(T1.importeGastoActivo, 0) - ISNULL(t2.importeImpuestos, 0)) AS Control
FROM #Temp1 t1
LEFT JOIN #Temp2 t2
    ON t1.EMPId = t2.EMPId
    AND t1.IMPORNumero = t2.IMPORNumero
    AND t1.NumeroIntDoc = t2.NumeroIntDoc
    AND t1.IMPTipoId = t2.IMPTipoId
    AND t1.FechaComprobante = t2.FechaComprobante
    AND t1.nroasiento = t2.nroasiento
ORDER BY t1.nroasiento;
	
	
	

	
	-- Eliminar tablas temporales
DROP TABLE #Temp1;
DROP TABLE #Temp2;

	end
	go
