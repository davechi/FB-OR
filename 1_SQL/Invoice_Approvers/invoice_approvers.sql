/*
Author: David Chi
Date Created: 2016-06-14
Tableau Workbooks: 
  Invoices - Cycle Times

Notes: Pulls all approvers for display by Invoice
*/  

select 
    a.invoice_id
    , i.invoice_num "Invoice #"
    , s.vendor_name Supplier
    , a.response
    , a.approver_id
    , a.approver_name Approver
    , i.WFAPPROVAL_STATUS
    , a.amount_approved
    , a.approver_comments
    , a.created_by
    , a.creation_date
    , a.last_update_date
    , a.last_updated_by
    , a.last_update_login
    , a.org_id
    , a.notification_order
    , a.orig_system
    , a.item_class
    , a.item_id
    , a.line_number
    , a.hold_id
    , a.history_type
    , RANK() OVER (PARTITION BY a.invoice_id ORDER BY a.creation_date asc) rank_create_date
    , RANK() OVER (PARTITION BY a.invoice_id ORDER BY a.last_update_date desc) rank_update_date
    , MAX(a.last_update_date) OVER (PARTITION BY a.invoice_id) last_approval_date
    , MAX(a.last_update_date) OVER (PARTITION BY a.invoice_id) - MIN(a.creation_date) OVER (PARTITION BY a.invoice_id) approval_cycle_time
    , COUNT(approval_history_id) OVER (PARTITION BY a.invoice_id) approval_history_count
    FROM ap.ap_invoices_all i 
    FULL JOIN apps.AP_INV_APRVL_HIST_ALL a
    ON a.invoice_id = i.invoice_id
    left outer join 
    apps.ap_suppliers s 
    on i.vendor_id = s.vendor_id
    
    -- Filters-------------------------------------------------------------
WHERE 1 = 1
AND i.invoice_date >= to_date('JAN-01-2015','MON-DD-YYYY')
AND i.invoice_date < SYSDATE + 30
