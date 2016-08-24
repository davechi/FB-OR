/*
Author: David Chi
Title: invoice_cy_py.sql
Date Created: 2016-05-28
Tableau Workbooks: 
  AP_metrics_automation.twbx

Notes: Get CY and PY into same row. Group by year, month, PO_NON_PO, infra, costcenter
*/

SELECT 
  op.invoice_date_year
  , op.invoice_date_month
  , TO_DATE(CONCAT(TO_CHAR(op.invoice_date_year), TO_CHAR(op.invoice_date_month)), 'yyyymm') invoice_date

  , op.invoice_date_year - CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER) ROLLING_FISCAL_YEAR

  , (op.invoice_date_year - CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER)) * 12 
    - (CAST(TO_CHAR(SYSDATE, 'mm') AS INTEGER) - op.invoice_date_month) ROLLING_FISCAL_MONTH

  , op.PO_NON_PO
  , op.infra_flag
  , op.costcenter
  , op.org_name
  , CASE 
     WHEN REPLACE(op.org_name, '''')
       IN ('Facebook Australia Operating Unit', 'Facebook Hong Kong Operating Unit', 'Facebook India Operating Unit', 'Facebook Japan Operating Unit', 'Facebook Korea Operating Unit', 'Facebook Mexico Operating Unit', 'Facebook New Zealand Operating Unit', 'Facebook Singapore Operating Unit') 
       THEN 'APAC'
     WHEN REPLACE(op.org_name, '''')
       IN ('Edge Network Operating Unit', 'Facebook Denmark Operating Unit', 'Facebook Eurozone', 'Facebook Intl USD Operating Unit', 'Facebook Israel Operating Unit', 'Facebook Norway Operating Unit', 'Facebook Poland Operating Unit', 'Facebook South Africa Operating Unit', 'Facebook Sweden Operating Unit', 'Facebook UAE Operating Unit', 'Facebook UK Operating Unit', 'Pinnacle Sweden Operating Unit', 'Facebook Payments Intl Ltd.')
       THEN 'EMEA'
     WHEN REPLACE(op.org_name, '''')
       IN ('Facebook Argentina Operating Unit', 'Facebook Colombia Operating Unit', 'Facebook Brazil Operating Unit')
       THEN 'LATAM'
     WHEN REPLACE(op.org_name, '''')
       IN ('Facebook Canada Operating Unit', 'Facebook Payments, Inc.', 'Facebook US')
       THEN 'NORAM'
     END Region
  , cy.invoice_count invoice_count_cy
  , cy.Invoice_Amount_USD invoice_amount_usd_cy
  , py.invoice_count invoice_count_py
  , py.Invoice_Amount_USD invoice_amount_usd_py
FROM
(
  SELECT
  invoice_date_year
  , invoice_date_month
  , PO_NON_PO
  , infra_flag
  , costcenter
  , org_id
  , org_name
  FROM
  (
    SELECT DISTINCT
    CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER) invoice_date_year
    , CAST(TO_CHAR(i.INVOICE_DATE, 'mm') AS INTEGER) invoice_date_month
    , 0 PO_NON_PO
    , org_id
    , hou.name org_name
    FROM ap.ap_invoices_all i
    LEFT JOIN
    apps.hr_operating_units hou 
    on hou.ORGANIZATION_ID = i.org_id
    WHERE CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER) >= CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER)-1
    UNION
 SELECT DISTINCT
    CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER) invoice_date_year
    , CAST(TO_CHAR(i.INVOICE_DATE, 'mm') AS INTEGER) invoice_date_month
    , 1 PO_NON_PO
    , org_id
    , hou.name Org_Name
    FROM ap.ap_invoices_all i
    LEFT JOIN
    apps.hr_operating_units hou 
    on hou.ORGANIZATION_ID = i.org_id
    WHERE CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER) >= CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER)-1
    ) my

  CROSS JOIN

    (
    SELECT DISTINCT
    CASE WHEN
      CASE WHEN gcc.segment2 in ('4110','4220','4310','4320','4330','4340','4350','4360','4390','5546') 
      THEN 1 ELSE 0 END = 1 
    THEN 'Infra' 
    ELSE 'Non-infra' 
    END infra_flag
    , gcc.segment2||'-'|| f1.description as CostCenter
    from apps.ap_invoice_distributions_all id,
    apps.gl_code_combinations gcc
    , apps.fnd_flex_values_vl f1
    where id.dist_code_combination_id = gcc.code_combination_id 
    and f1.flex_value_set_id = 1013508
    and gcc.segment2 = f1.flex_value
    ) cc
) op

LEFT JOIN

(
select
CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER) invoice_date_year
, CAST(TO_CHAR(i.INVOICE_DATE, 'mm') AS INTEGER) invoice_date_month
, NVL(infra.infra_flag, 'Non-infra') infra_flag
, NVL(infra.CostCenter, '0000-Default') costcenter
, org_id
, CASE ponpo.PO_NON_PO WHEN 0 THEN 0 ELSE 1 END PO_NON_PO
, COUNT(DISTINCT i.invoice_id) invoice_count
, SUM(i.Invoice_Amount * DECODE(i.invoice_currency_code,'USD',1,
  (
  SELECT conversion_rate
  FROM apps.gl_daily_rates
  WHERE from_currency = i.invoice_currency_code
  AND to_currency = 'USD'
  AND conversion_Date = i.invoice_date
  AND conversion_type = 'Corporate'
 )
 )) Invoice_Amount_USD

FROM ap.ap_invoices_all i 
LEFT JOIN 
(
  SELECT id.invoice_id, 
  CASE WHEN sum
  (case when gcc.segment2 in ('4110','4220','4310','4320','4330','4340','4350','4360','4390','5546') 
    then 1 else 0 end) > 0 then 'Infra' 
    else 'Non-infra' 
    end infra_flag
  , NVL(MIN(case gcc.segment2 ||'-'|| f1.description
    WHEN '4110-'|| f1.description THEN '4110-'|| f1.description
    WHEN '4220-'|| f1.description THEN '4220-'|| f1.description
    WHEN '4310-'|| f1.description THEN '4310-'|| f1.description
    WHEN '4320-'|| f1.description THEN '4320-'|| f1.description
    WHEN '4330-'|| f1.description THEN '4330-'|| f1.description
    WHEN '4340-'|| f1.description THEN '4340-'|| f1.description
    WHEN '4350-'|| f1.description THEN '4350-'|| f1.description
    WHEN '4360-'|| f1.description THEN '4360-'|| f1.description
    WHEN '4390-'|| f1.description THEN '4390-'|| f1.description
    WHEN '5546-'|| f1.description THEN '5546-'|| f1.description
    ELSE NULL end), MAX(gcc.segment2 ||'-'|| f1.description))
    as CostCenter
  from apps.ap_invoice_distributions_all id,
  apps.gl_code_combinations gcc
  , apps.fnd_flex_values_vl f1
  where id.dist_code_combination_id = gcc.code_combination_id 
    and f1.flex_value_set_id = 1013508
    and gcc.segment2 = f1.flex_value
  group by invoice_id
) infra 
ON i.invoice_id=infra.invoice_id
LEFT JOIN
(
  select idstr.invoice_id
  , sum(Case When IDSTR.PO_DISTRIBUTION_ID is null Then 1 Else 0 end) PO_NON_PO
  from 
  AP.AP_INVOICE_DISTRIBUTIONS_ALL IDSTR
  group by idstr.invoice_id
) ponpo 
ON ponpo.invoice_id = i.invoice_id 

WHERE 1=1
AND CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER) = CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER)

GROUP BY 
  CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER)
  , CAST(TO_CHAR(i.INVOICE_DATE, 'mm') AS INTEGER)
  , NVL(infra.infra_flag, 'Non-infra') 
  , NVL(infra.CostCenter, '0000-Default')
  , org_id
  , CASE ponpo.PO_NON_PO WHEN 0 THEN 0 ELSE 1 END
) cy
ON op.invoice_date_year = cy.invoice_date_year
  AND op.invoice_date_month  = cy.invoice_date_month
  AND op.PO_NON_PO = cy.PO_NON_PO
  AND op.infra_flag = cy.infra_flag
  AND op.costcenter = cy.costcenter
  AND op.org_id = cy.org_id
  
LEFT JOIN

(
select
CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER) invoice_date_year
, CAST(TO_CHAR(i.INVOICE_DATE, 'mm') AS INTEGER) invoice_date_month
, NVL(infra.infra_flag, 'Non-infra') infra_flag
, NVL(infra.CostCenter, '0000-Default') costcenter
, org_id
, CASE ponpo.PO_NON_PO WHEN 0 THEN 0 ELSE 1 END PO_NON_PO
, COUNT(DISTINCT i.invoice_id) invoice_count
, SUM(i.Invoice_Amount * DECODE(i.invoice_currency_code,'USD',1,
  (
  SELECT conversion_rate
  FROM apps.gl_daily_rates
  WHERE from_currency = i.invoice_currency_code
  AND to_currency = 'USD'
  AND conversion_Date = i.invoice_date
  AND conversion_type = 'Corporate'
 )
 )) Invoice_Amount_USD

FROM ap.ap_invoices_all i 
LEFT JOIN 
(
  SELECT id.invoice_id, 
  CASE WHEN sum
  (case when gcc.segment2 in ('4110','4220','4310','4320','4330','4340','4350','4360','4390','5546') 
    then 1 else 0 end) > 0 then 'Infra' 
    else 'Non-infra' 
    end infra_flag
  , NVL(MIN(case gcc.segment2 ||'-'|| f1.description
    WHEN '4110-'|| f1.description THEN '4110-'|| f1.description
    WHEN '4220-'|| f1.description THEN '4220-'|| f1.description
    WHEN '4310-'|| f1.description THEN '4310-'|| f1.description
    WHEN '4320-'|| f1.description THEN '4320-'|| f1.description
    WHEN '4330-'|| f1.description THEN '4330-'|| f1.description
    WHEN '4340-'|| f1.description THEN '4340-'|| f1.description
    WHEN '4350-'|| f1.description THEN '4350-'|| f1.description
    WHEN '4360-'|| f1.description THEN '4360-'|| f1.description
    WHEN '4390-'|| f1.description THEN '4390-'|| f1.description
    WHEN '5546-'|| f1.description THEN '5546-'|| f1.description
    ELSE NULL end), MAX(gcc.segment2 ||'-'|| f1.description))
    as CostCenter
  from apps.ap_invoice_distributions_all id,
  apps.gl_code_combinations gcc
  , apps.fnd_flex_values_vl f1
  where id.dist_code_combination_id = gcc.code_combination_id 
    and f1.flex_value_set_id = 1013508
    and gcc.segment2 = f1.flex_value
  group by invoice_id
) infra 
ON i.invoice_id=infra.invoice_id
LEFT JOIN
(
  select idstr.invoice_id
  , sum(Case When IDSTR.PO_DISTRIBUTION_ID is null Then 1 Else 0 end) PO_NON_PO
  from 
  AP.AP_INVOICE_DISTRIBUTIONS_ALL IDSTR
  group by idstr.invoice_id
) ponpo 
ON ponpo.invoice_id = i.invoice_id 

WHERE CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER) = CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER) - 1
GROUP BY 
  CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER)
  , CAST(TO_CHAR(i.INVOICE_DATE, 'mm') AS INTEGER)
  , NVL(infra.infra_flag, 'Non-infra') 
  , NVL(infra.CostCenter, '0000-Default')
   ,org_id
  , CASE ponpo.PO_NON_PO WHEN 0 THEN 0 ELSE 1 END
) py
ON op.invoice_date_year - 1 = py.invoice_date_year
  AND op.invoice_date_month  = py.invoice_date_month
  AND op.PO_NON_PO = py.PO_NON_PO
  AND op.infra_flag = py.infra_flag
  AND op.costcenter = py.costcenter
  AND op.org_id = py.org_id

where 1=1
ORDER BY infra_flag, costcenter, po_non_po, invoice_date_year, invoice_date_month