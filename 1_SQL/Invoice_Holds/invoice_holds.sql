/*
Author: David Chi
Date Created: 2016-06-16
Tableau Workbooks: 
  Invoices - Cycle Times

Notes: Pulls all holds for display by Invoice
*/  

select 
    i.invoice_num "Invoice #"
    , s.vendor_name Supplier
    , ah.invoice_id
    , ah.hold_id
    , ah.hold_reason
    , ah.hold_lookup_code
    , ah.release_lookup_code
    , ah.release_reason
    , count(ah.hold_id) over (partition by ah.invoice_id) cnt
    , ah.hold_date first_hold_date
    , ah.last_update_date last_hold_release_date
    , COALESCE(ah.last_update_date, SYSDATE) - ah.hold_date hold_duration
    FROM ap.ap_invoices_all i 
    FULL JOIN apps.ap_holds_all ah
    ON i.invoice_id = ah.invoice_id
    left outer join 
    apps.ap_suppliers s 
    on i.vendor_id = s.vendor_id
    
    -- Filters-------------------------------------------------------------
WHERE 1 = 1
--AND i.invoice_date >= to_date('JAN-01-2015','MON-DD-YYYY')
--AND i.invoice_date < SYSDATE + 30
