/*
Author: David Chi
Date Created: 2016-05-25
Tableau Workbooks: 
  APInvoice_DC_6.twbx
  Accounts_Payable_Metrics.twbx

Notes: Categorizes holds into Pre-Approval, Overlapping-Approval, and Post-Approval
*/


SELECT
s.vendor_name
, i.invoice_id
, i.invoice_num
, i.source
, i.invoice_type_lookup_code
, i.org_id
, infra.CostCenter
, NVL(infra.infra_flag, 'Non-infra') infra_flag

, hou.name Org_Name
, CASE 
   WHEN REPLACE(hou.name, '''')
     IN ('Facebook Australia Operating Unit', 'Facebook Hong Kong Operating Unit', 'Facebook India Operating Unit', 'Facebook Japan Operating Unit', 'Facebook Korea Operating Unit', 'Facebook Mexico Operating Unit', 'Facebook New Zealand Operating Unit', 'Facebook Singapore Operating Unit') 
     THEN 'APAC'
   WHEN REPLACE(hou.name, '''')
     IN ('Edge Network Operating Unit', 'Facebook Denmark Operating Unit', 'Facebook Eurozone', 'Facebook Intl USD Operating Unit', 'Facebook Israel Operating Unit', 'Facebook Norway Operating Unit', 'Facebook Poland Operating Unit', 'Facebook South Africa Operating Unit', 'Facebook Sweden Operating Unit', 'Facebook UAE Operating Unit', 'Facebook UK Operating Unit', 'Pinnacle Sweden Operating Unit', 'Facebook Payments Intl Ltd.')
     THEN 'EMEA'
   WHEN REPLACE(hou.name, '''')
     IN ('Facebook Argentina Operating Unit', 'Facebook Colombia Operating Unit', 'Facebook Brazil Operating Unit')
     THEN 'LATAM'
   WHEN REPLACE(hou.name, '''')
     IN ('Facebook Canada Operating Unit', 'Facebook Payments, Inc.', 'Facebook US')
     THEN 'NORAM'
   END Region

, i.vendor_id
, i.vendor_site_id
, i.INVOICE_DATE

, CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER) - CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER) ROLLING_FISCAL_YEAR

, (CAST(TO_CHAR(i.INVOICE_DATE, 'yyyy') AS INTEGER) - CAST(TO_CHAR(SYSDATE, 'yyyy') AS INTEGER)) * 12 
  - (CAST(TO_CHAR(SYSDATE, 'mm') AS INTEGER) - CAST(TO_CHAR(i.INVOICE_DATE, 'mm') AS INTEGER)) ROLLING_FISCAL_MONTH

, i.INVOICE_RECEIVED_DATE
, i.CREATION_DATE entered_date
, i.terms_date
, i.terms_date + nvl(l.due_days,0) due_date

, h.hold_pre_hold_id
, h.hold_pre_cnt
, h.hold_pre_first_hold_date
, h.hold_pre_hold_release_date
, h.hold_pre_hold_duration
, h.hold_pre_hold_reason
, h.hold_pre_hold_lookup_code
, h.hold_pre_release_lookup_code
, h.hold_pre_release_reason

, h.hold_ovlp_hold_id
, h.hold_ovlp_cnt
, h.hold_ovlp_first_hold_date
, h.hold_ovlp_hold_release_date
, h.hold_ovlp_hold_duration
, h.hold_ovlp_hold_reason
, h.hold_ovlp_hold_lookup_code
, h.hold_ovlp_release_lookup_code
, h.hold_ovlp_release_reason

, h.hold_post_hold_id
, h.hold_post_cnt
, h.hold_post_first_hold_date
, h.hold_post_hold_release_date
, h.hold_post_hold_duration
, h.hold_post_hold_reason
, h.hold_post_hold_lookup_code
, h.hold_post_release_lookup_code
, h.hold_post_release_reason

, a.validation_date
, a.approver_first
, a.last_approval_date
, a.approver_last

, first_payment_creation_date
, last_payment_creation_date
, last_check_date
, last_cleared_date
, receipt_required
, receipt_not_required
, p.last_check_date as Payment_Date
, l.due_days
, ps.Payment_Due_Date
, tl.Name
, tl.DESCRIPTION
, i.INVOICE_AMOUNT
, i.Invoice_Amount * DECODE(i.invoice_currency_code,'USD',1,
  (
  SELECT conversion_rate
  FROM apps.gl_daily_rates
  WHERE from_currency = i.invoice_currency_code
  AND to_currency = 'USD'
  AND conversion_Date = i.invoice_date
  AND conversion_type = 'Corporate'
 )
 ) Invoice_Amount_USD

, i.AMOUNT_PAID
, PO_NON_PO
, ( 
    Select Max(CREATION_DATE)
    From apps.xxfb_ap_sup_sites_audit aa     
    Where Hold_All_Payments_Flag_new='Y'
    and aa.Vendor_ID=i.Vendor_Id and aa.Vendor_Site_ID=i.VENDOR_SITE_ID
    and aa.CREATION_DATE >= a.last_approval_date
  ) as Max_Hold_Release_Date 

-- Tables (ap_invoices_all)

FROM ap.ap_invoices_all i 
LEFT outer Join
  (select 
    inpay.invoice_id
    , min(inpay.creation_date) first_payment_creation_date
    , max(inpay.creation_date) last_payment_creation_date
    , max(chk.check_date) last_check_date
    , max(chk.cleared_date) last_cleared_date 
   from AP.AP_INVOICE_PAYMENTS_ALL INPAY, ap.ap_checks_all chk
   where chk.check_id=inpay.check_id
   and CHK.STATUS_LOOKUP_CODE <>'VOIDED'
   AND NVL(CHK.ORG_ID, NVL(INPAY.ORG_ID, -9999))= NVL(INPAY.ORG_ID, -9999)
   group by invoice_id
   ) p 
  ON p.invoice_id=i.invoice_id 
LEFT OUTER JOIN 
  (
   select idstr.invoice_id
   , sum(case when shipm.receipt_required_flag='Y' then 1 else 0 end) receipt_required
   , sum(case when shipm.receipt_required_flag='N' then 1 else 0 end) receipt_NOT_required
   , sum(Case When IDSTR.PO_DISTRIBUTION_ID is null Then 1 Else 0 end) PO_NON_PO
   from 
   AP.AP_INVOICE_DISTRIBUTIONS_ALL IDSTR,
   PO.PO_LINE_LOCATIONS_ALL SHIPM,
   PO.PO_DISTRIBUTIONS_ALL PDSTR
   WHERE 1=1
   AND SHIPM.LINE_LOCATION_ID(+) = PDSTR.LINE_LOCATION_ID
   AND PDSTR.PO_DISTRIBUTION_ID(+) = IDSTR.PO_DISTRIBUTION_ID
   group by idstr.invoice_id
  ) twothree 
  ON twothree.invoice_id = i.invoice_id 

-- Hold Categories and Dates ------------------------------------------------

LEFT OUTER JOIN 
   (
  SELECT 
    COALESCE(hold_pre_appr.invoice_id, hold_overlap_appr.invoice_id, hold_post_appr.invoice_id) invoice_id
    , MIN(hold_pre_appr.hold_id) hold_pre_hold_id
    , MIN(hold_pre_appr.cnt) hold_pre_cnt
    , MIN(hold_pre_appr.first_hold_date) hold_pre_first_hold_date
    , MIN(hold_pre_appr.last_hold_release_date) hold_pre_hold_release_date
    , MIN(hold_pre_appr.hold_duration) hold_pre_hold_duration
    , MIN(hold_pre_appr.hold_reason) hold_pre_hold_reason
    , MIN(hold_pre_appr.hold_lookup_code) hold_pre_hold_lookup_code
    , MIN(hold_pre_appr.release_lookup_code) hold_pre_release_lookup_code
    , MIN(hold_pre_appr.release_reason) hold_pre_release_reason

    , MIN(hold_overlap_appr.hold_id) hold_ovlp_hold_id
    , MIN(hold_overlap_appr.cnt) hold_ovlp_cnt
    , MIN(hold_overlap_appr.first_hold_date) hold_ovlp_first_hold_date
    , MIN(hold_overlap_appr.last_hold_release_date) hold_ovlp_hold_release_date
    , MIN(hold_overlap_appr.hold_duration) hold_ovlp_hold_duration
    , MIN(hold_overlap_appr.hold_reason) hold_ovlp_hold_reason
    , MIN(hold_overlap_appr.hold_lookup_code) hold_ovlp_hold_lookup_code
    , MIN(hold_overlap_appr.release_lookup_code) hold_ovlp_release_lookup_code
    , MIN(hold_overlap_appr.release_reason) hold_ovlp_release_reason

    , MIN(hold_post_appr.hold_id) hold_post_hold_id
    , MIN(hold_post_appr.cnt) hold_post_cnt
    , MIN(hold_post_appr.first_hold_date) hold_post_first_hold_date
    , MIN(hold_post_appr.last_hold_release_date) hold_post_hold_release_date
    , MIN(hold_post_appr.hold_duration) hold_post_hold_duration
    , MIN(hold_post_appr.hold_reason) hold_post_hold_reason
    , MIN(hold_post_appr.hold_lookup_code) hold_post_hold_lookup_code
    , MIN(hold_post_appr.release_lookup_code) hold_post_release_lookup_code
    , MIN(hold_post_appr.release_reason) hold_post_release_reason
  
  FROM
  (  
    SELECT
      invoice_id
      , hold_id
      , cnt
      , first_hold_date
      , last_hold_release_date
      , hold_duration
      , hold_reason
      , hold_lookup_code
      , release_lookup_code
      , release_reason
      , 'Hold Pre-Approval' HOLD_CATEGORY
      , rank() over (partition by invoice_id order by hold_duration desc, hold_id desc) hold_line_rank
    FROM
    (
        SELECT
        ah.invoice_id
        , ah.hold_id
        , ah.hold_reason
        , ah.hold_lookup_code
        , ah.release_lookup_code
        , ah.release_reason
        , count(ah.hold_id) over (partition by ah.invoice_id) cnt
        , ah.hold_date first_hold_date
        , ah.last_update_date last_hold_release_date
        , COALESCE(ah.last_update_date, SYSDATE) - ah.hold_date hold_duration
        , ai.validation_date
        , ai.last_approval_date
    from apps.ap_holds_all ah
    LEFT JOIN
    (
        SELECT invoice_id
      , min(creation_date) validation_date
      , max(last_update_date) last_approval_date 
      from apps.AP_INV_APRVL_HIST_ALL group by invoice_id
      ) ai
    ON ah.invoice_id = ai.invoice_id
    AND ai.validation_date is not null
    WHERE ah.hold_date < COALESCE(ai.validation_date, SYSDATE) 
    AND COALESCE(ah.last_update_date, SYSDATE) <= COALESCE(ai.validation_date, SYSDATE) 
    ORDER BY cnt desc, hold_duration desc
  ) h 
  ) hold_pre_appr
  FULL JOIN
  (  
  SELECT
      invoice_id
      , hold_id
      , cnt
      , first_hold_date
      , last_hold_release_date
      , hold_duration
      , hold_reason
      , hold_lookup_code
      , release_lookup_code
      , release_reason
      , 'Hold Overlap-Approval' HOLD_CATEGORY
      , rank() over (partition by invoice_id order by hold_duration desc, hold_id desc) hold_line_rank
    FROM
    (
        SELECT
        ah.invoice_id
        , ah.hold_id
        , ah.hold_reason
        , ah.hold_lookup_code
        , ah.release_lookup_code
        , ah.release_reason
        , count(ah.hold_id) over (partition by ah.invoice_id) cnt
        , ah.hold_date first_hold_date
        , ah.last_update_date last_hold_release_date
        , COALESCE(ah.last_update_date, SYSDATE) - ah.hold_date hold_duration
        , ai.validation_date
        , ai.last_approval_date
    from apps.ap_holds_all ah
    LEFT JOIN
    (
        SELECT invoice_id
      , min(creation_date) validation_date
      , max(last_update_date) last_approval_date 
      from apps.AP_INV_APRVL_HIST_ALL group by invoice_id
      ) ai
    ON ah.invoice_id = ai.invoice_id
    AND ai.validation_date is not null
    WHERE ((ah.hold_date BETWEEN ai.validation_date AND ai.last_approval_date) OR COALESCE(ah.last_update_date, SYSDATE) BETWEEN ai.validation_date AND ai.validation_date)
    ORDER BY cnt desc, hold_duration desc
  ) h 
  ) hold_overlap_appr
  ON hold_pre_appr.invoice_id = hold_overlap_appr.invoice_id
  FULL JOIN
  (  
  SELECT
      invoice_id
      , hold_id
      , cnt
      , first_hold_date
      , last_hold_release_date
      , hold_duration
      , hold_reason
      , hold_lookup_code
      , release_lookup_code
      , release_reason
      , 'Hold Post-Approval' HOLD_CATEGORY
      , rank() over (partition by invoice_id order by hold_duration desc, hold_id desc) hold_line_rank
    FROM
    (
        SELECT
        ah.invoice_id
        , ah.hold_id
        , ah.hold_reason
        , ah.hold_lookup_code
        , ah.release_lookup_code
        , ah.release_reason
        , count(ah.hold_id) over (partition by ah.invoice_id) cnt
        , ah.hold_date first_hold_date
        , ah.last_update_date last_hold_release_date
        , COALESCE(ah.last_update_date, SYSDATE) - ah.hold_date hold_duration
        , ai.validation_date
        , ai.last_approval_date
    from apps.ap_holds_all ah
    LEFT JOIN
    (
        SELECT invoice_id
      , min(creation_date) validation_date
      , max(last_update_date) last_approval_date 
      from apps.AP_INV_APRVL_HIST_ALL group by invoice_id
      ) ai
    ON ah.invoice_id = ai.invoice_id
    AND ai.validation_date is not null
    WHERE (ah.hold_date >= ai.last_approval_date AND ah.last_update_date >= ai.last_approval_date) 
    ORDER BY cnt desc, hold_duration desc
  ) h 
  ) hold_post_appr
  ON hold_pre_appr.invoice_id = hold_post_appr.invoice_id
  where 1 = 1
  AND COALESCE(hold_pre_appr.hold_line_rank, 1) = 1
  AND COALESCE(hold_overlap_appr.hold_line_rank, 1) = 1
  AND COALESCE(hold_post_appr.hold_line_rank, 1) = 1
  
  group by COALESCE(hold_pre_appr.invoice_id, hold_overlap_appr.invoice_id, hold_post_appr.invoice_id)
  ) h 
  ON i.invoice_id = h.invoice_id

-- Validation, Approval Dates and Approvers --------------------------------------------------------

LEFT OUTER JOIN 
  (
  SELECT 
  invoice_id
  , MIN(DECODE(rank_create_date, 1, creation_date)) validation_date
  , MIN(DECODE(rank_create_date, 1, approver_name)) approver_first
  , MIN(DECODE(rank_update_date, 1, last_approval_date)) last_approval_date
  , MIN(DECODE(rank_update_date, 1, approver_name)) approver_last
  FROM
  (
    select 
    invoice_id
    , creation_date
    , approver_name
    , RANK() OVER (PARTITION BY invoice_id ORDER BY creation_date asc) rank_create_date
    , last_update_date
    , RANK() OVER (PARTITION BY invoice_id ORDER BY last_update_date desc) rank_update_date
    , MAX(last_update_date) OVER (PARTITION BY invoice_id) last_approval_date
    FROM apps.AP_INV_APRVL_HIST_ALL 
    where 1=1
    ) x
  WHERE rank_create_date = 1 or rank_update_date = 1
  GROUP BY invoice_id
  ) 
  a on i.invoice_id=a.invoice_id 

-- Infra --------------------------------------------------------

LEFT JOIN 
(
  SELECT 
  id.invoice_id
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

-- Invoice metadata---------------------------------------------------

LEFT OUTER JOIN
 (select term_id
  , due_days 
  from apps.ap_terms_lines l 
  where sequence_num = 1) l 
  ON i.terms_id = l.term_id
left outer join 
  apps.ap_suppliers s 
  on i.vendor_id = s.vendor_id
Left outer Join 
  apps.hr_operating_units hou 
  on hou.ORGANIZATION_ID = i.org_id
Left Outer Join 
 (Select Invoice_ID
  , Max(Due_date) Payment_Due_Date 
  From apps.AP_PAYMENT_SCHEDULES_ALL 
  group by InvoicE_ID) Ps 
  on Ps.Invoice_ID = i.INVOICE_ID
Left Outer Join 
 (Select Term_ID, Name
  , apt.DESCRIPTION
  From apps. AP_TERMS_TL apt
  Where 1=1 
  AND apt.enabled_flag='Y'
  AND apt.language='US') TL 
 ON TL.Term_ID = i.Terms_ID


-- Filters------------------------------------------------------------- 
WHERE 1 = 1
AND i.invoice_date >= to_date('JAN-01-2015','MON-DD-YYYY')
AND i.invoice_date < SYSDATE + 30