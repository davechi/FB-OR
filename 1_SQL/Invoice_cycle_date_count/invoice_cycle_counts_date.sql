SELECT
op.fiscal_week
, (ROUND(op.fiscal_week,'DAY') - ROUND(sysdate, 'DAY'))/7 rolling_fiscal_week   
, op.PO_NON_PO
, op.infra_flag
, op.costcenter_id
, op.costcenter
, op.org_id
, op.org_name

, invoice_entry.invoice_count invoices_count_entry

FROM
  (
  SELECT
  fiscal_week
  , PO_NON_PO
  , infra_flag
  , costcenter_id
  , costcenter
  , org_id
  , org_name
  FROM
    (
    SELECT DISTINCT
    ROUND(last_update_date,'DAY') fiscal_week 
    , 0 PO_NON_PO
    , org_id
    , hou.name org_name
    FROM ap.ap_invoices_all i
    LEFT JOIN
    apps.hr_operating_units hou 
    on hou.ORGANIZATION_ID = i.org_id
    UNION
    SELECT DISTINCT
    ROUND(last_update_date,'DAY') fiscal_week
    , 1 PO_NON_PO
    , org_id
    , hou.name org_name
    FROM ap.ap_invoices_all i
    LEFT JOIN
    apps.hr_operating_units hou 
    ON hou.ORGANIZATION_ID = i.org_id
    ) fw
    
  CROSS JOIN

    (
    SELECT DISTINCT
    gcc.segment2 costcenter_id
    , CASE WHEN
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

-- Invoice Entry
  LEFT JOIN
  (
    SELECT
    ROUND(CREATION_DATE,'DAY') fiscal_week_entry
    , NVL(infra.infra_flag, 'Non-infra') infra_flag
    , NVL(infra.costcenter_id, '0000') costcenter_id
    , NVL(infra.CostCenter, '0000-Default') costcenter
    , org_id
    , CASE ponpo.PO_NON_PO WHEN 0 THEN 0 ELSE 1 END PO_NON_PO
    , COUNT(DISTINCT i.invoice_id) invoice_count

    FROM ap.ap_invoices_all i
    LEFT JOIN 
    (
      SELECT id.invoice_id
      , MIN(gcc.segment2) costcenter_id
      , CASE WHEN sum
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
        ROUND(CREATION_DATE,'DAY')
      , NVL(infra.costcenter_id, '0000')
      , NVL(infra.infra_flag, 'Non-infra') 
      , NVL(infra.CostCenter, '0000-Default')
      , org_id
      , CASE ponpo.PO_NON_PO WHEN 0 THEN 0 ELSE 1 END
    ) invoice_entry
    ON 
    op.fiscal_week = invoice_entry.fiscal_week_entry
    AND op.po_non_po = invoice_entry.po_non_po
    AND op.org_id = invoice_entry.org_id
    AND op.costcenter_id = invoice_entry.costcenter_id

-- Invoice Hold
  LEFT JOIN
  (
    SELECT
    ROUND(CREATION_DATE,'DAY') fiscal_week_entry
    , NVL(infra.infra_flag, 'Non-infra') infra_flag
    , NVL(infra.costcenter_id, '0000') costcenter_id
    , NVL(infra.CostCenter, '0000-Default') costcenter
    , org_id
    , CASE ponpo.PO_NON_PO WHEN 0 THEN 0 ELSE 1 END PO_NON_PO
    , COUNT(DISTINCT i.invoice_id) invoice_count

    FROM ap.ap_invoices_all i
    LEFT JOIN 
    (
      SELECT id.invoice_id
      , MIN(gcc.segment2) costcenter_id
      , CASE WHEN sum
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
        ROUND(CREATION_DATE,'DAY')
      , NVL(infra.costcenter_id, '0000')
      , NVL(infra.infra_flag, 'Non-infra') 
      , NVL(infra.CostCenter, '0000-Default')
      , org_id
      , CASE ponpo.PO_NON_PO WHEN 0 THEN 0 ELSE 1 END
    ) invoice_entry
    ON 
    op.fiscal_week = invoice_entry.fiscal_week_entry
    AND op.po_non_po = invoice_entry.po_non_po
    AND op.org_id = invoice_entry.org_id
    AND op.costcenter_id = invoice_entry.costcenter_id
    
    
    ORDER BY fiscal_week desc