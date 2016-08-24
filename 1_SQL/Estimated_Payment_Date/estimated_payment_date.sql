/*
Author: David Chi
Date Created: 2016-07-12
Tableau Workbooks:
 
Notes: Estimated Payment Date query

*/


SELECT

INVOICE_ID
, LATEST_DATE
 + CASE LATEST_STATUS
   WHEN 'CANCELLED'                   THEN 0
   WHEN 'PAID'                        THEN 0
   WHEN 'FIRST CHECK'                 THEN 1
   WHEN 'LAST PAYMENT CREATED'        THEN 2
   WHEN 'FIRST PAYMENT CREATED'       THEN 3
   WHEN 'POST-APPROVAL HOLD RELEASED' THEN 5
   WHEN 'POST-APPROVAL HOLD'          THEN 10
   WHEN 'APPROVED'                    THEN 5
   WHEN 'VALIDATED'                   THEN 5.5
   WHEN 'PRE-APPROVAL HOLD RELEASED'  THEN 6
   WHEN 'PRE-APPROVAL HOLD'           THEN 11
   WHEN 'ENTERED'                     THEN 10
   WHEN 'RECEIVED'                    THEN 15
   WHEN 'INVOICE CREATED'             THEN 20
   END ESTIMATED_PAYMENT_DATE
, 0 AS ML_VERSION
, SYSDATE AS CREATED_DATE 
, 216575 AS CREATED_BY
, SYSDATE AS LAST_UPDATED_DATE
, 216575 AS LAST_UPDATED_BY

FROM

(
SELECT
i.invoice_id
, i.terms_date + nvl(l.due_days,0) due_date
, ps.Payment_Due_Date

, NVL(i.cancelled_date,
  NVL(p.last_check_date, 
  NVL(p.first_check_date, 
  NVL(last_payment_creation_date,
  NVL(first_payment_creation_date,
  NVL(CASE NVL(h.hold_post_release_reason, 'X') WHEN 'X' THEN NULL ELSE h.hold_post_hold_release_date END,
  NVL(h.hold_post_first_hold_date,
  NVL(a.last_approval_date,
  NVL(a.validation_date,
  NVL(CASE NVL(h.hold_pre_release_reason, 'X') WHEN 'X' THEN NULL ELSE h.hold_pre_hold_release_date END,
  NVL(h.hold_pre_first_hold_date,
  NVL(i.CREATION_DATE,
  NVL(i.INVOICE_RECEIVED_DATE, i.INVOICE_DATE
  ))))))))))))) LATEST_DATE

, CASE
  NVL(i.cancelled_date,
  NVL(p.last_check_date, 
  NVL(p.first_check_date, 
  NVL(last_payment_creation_date,
  NVL(first_payment_creation_date,
  NVL(CASE NVL(h.hold_post_release_reason, 'X') WHEN 'X' THEN NULL ELSE h.hold_post_hold_release_date END,
  NVL(h.hold_post_first_hold_date,
  NVL(a.last_approval_date,
  NVL(a.validation_date,
  NVL(CASE NVL(h.hold_pre_release_reason, 'X') WHEN 'X' THEN NULL ELSE h.hold_pre_hold_release_date END,
  NVL(h.hold_pre_first_hold_date,
  NVL(i.CREATION_DATE,
  NVL(i.INVOICE_RECEIVED_DATE, i.INVOICE_DATE
  )))))))))))))
  WHEN i.cancelled_date THEN 'CANCELLED'
  WHEN p.last_check_date THEN 'PAID'
  WHEN p.first_check_date THEN 'FIRST CHECK'
  WHEN last_payment_creation_date THEN 'LAST PAYMENT CREATED'
  WHEN first_payment_creation_date THEN 'FIRST PAYMENT CREATED'
  WHEN (CASE NVL(h.hold_post_release_reason, 'X') WHEN 'X' THEN NULL ELSE h.hold_post_hold_release_date END) THEN 'POST-APPROVAL HOLD RELEASED'
  WHEN h.hold_post_first_hold_date THEN 'POST-APPROVAL HOLD'
  WHEN a.last_approval_date THEN 'APPROVED'
  WHEN a.validation_date THEN 'VALIDATED'
  WHEN (CASE NVL(h.hold_pre_release_reason, 'X') WHEN 'X' THEN NULL ELSE h.hold_pre_hold_release_date END) THEN 'PRE-APPROVAL HOLD RELEASED'
  WHEN h.hold_pre_first_hold_date THEN 'PRE-APPROVAL HOLD'
  WHEN i.CREATION_DATE THEN 'ENTERED'
  WHEN i.INVOICE_RECEIVED_DATE THEN 'RECEIVED'
  WHEN i.INVOICE_DATE THEN 'INVOICE CREATED'
  END LATEST_STATUS
  
, i.INVOICE_DATE
, i.INVOICE_RECEIVED_DATE
, i.CREATION_DATE entered_date
, h.hold_pre_first_hold_date
, h.hold_pre_hold_release_date
, h.hold_pre_release_reason

, a.validation_date
, a.last_approval_date
 
, h.hold_post_first_hold_date
, h.hold_post_hold_release_date
, h.hold_post_release_reason
 
, i.cancelled_date

, CASE NVL(i.cancelled_date, TO_DATE('1/1/1900', 'mm/dd/yyyy')) 
  WHEN TO_DATE('1/1/1900', 'mm/dd/yyyy') 
  THEN 'active' ELSE 'cancelled' END CANCEL_STATUS
, first_payment_creation_date
, first_check_date
, p.last_check_date as Payment_Date
 
-- Tables (ap_invoices_all)
 
FROM ap.ap_invoices_all i
LEFT outer Join
  (select
    inpay.invoice_id
    , min(inpay.creation_date) first_payment_creation_date
    , max(inpay.creation_date) last_payment_creation_date
    , min(chk.check_date) first_check_date
    , max(chk.check_date) last_check_date
    , max(chk.cleared_date) last_cleared_date
   from AP.AP_INVOICE_PAYMENTS_ALL INPAY, ap.ap_checks_all chk
   where chk.check_id=inpay.check_id
   group by invoice_id
   ) p
  ON p.invoice_id=i.invoice_id

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
  , MIN(DECODE(rank_update_date, 1, response)) approval_response
  FROM
  (
    select
    invoice_id
    , creation_date
    , approver_name
    , response
    , RANK() OVER (PARTITION BY invoice_id ORDER BY creation_date asc) rank_create_date
    , last_update_date
    , RANK() OVER (PARTITION BY invoice_id ORDER BY last_update_date desc) rank_update_date
    , MAX(last_update_date) OVER (PARTITION BY invoice_id) last_approval_date
    FROM apps.AP_INV_APRVL_HIST_ALL
    where 1=1
    order by invoice_id
    ) x
  WHERE rank_create_date = 1 or rank_update_date = 1
  GROUP BY invoice_id
  )
  a on i.invoice_id=a.invoice_id
 
-- Invoice metadata---------------------------------------------------
 
LEFT OUTER JOIN
(select term_id
  , due_days
  from apps.ap_terms_lines l
  where sequence_num = 1) l
  ON i.terms_id = l.term_id

Left Outer Join
 (Select Invoice_ID
  , Max(Due_date) Payment_Due_Date
  From apps.AP_PAYMENT_SCHEDULES_ALL
  group by InvoicE_ID) Ps
  on Ps.Invoice_ID = i.INVOICE_ID
 
 
-- Filters-------------------------------------------------------------
WHERE 1 = 1
AND p.last_check_date IS NULL

)
ORDER BY ESTIMATED_PAYMENT_DATE desc
