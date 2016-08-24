SELECT 
distinct 
c_inv.invoice_num_base
, i.invoice_num
, i.vendor_id
, count(*) over (partition by c_inv.invoice_num_base) base_count

FROM

(
SELECT
invoice_num
, CASE SUBSTR(invoice_num, 1, 3)
  WHEN 'DCR' THEN SUBSTR(invoice_num,4,length(invoice_num)-3)
  WHEN 'DDR' THEN SUBSTR(invoice_num,4,length(invoice_num)-3)
  ELSE SUBSTR(invoice_num, 1, length(invoice_num)-1)
  END invoice_num_base
, vendor_id
FROM ap.ap_invoices_all
WHERE 1=1
AND (REGEXP_LIKE(invoice_num, '(DCR)|(DDR)^')
  OR REGEXP_LIKE(invoice_num, '(R|A|B|C)$'))
ORDER BY 2
) c_inv

INNER JOIN

ap.ap_invoices_all i
ON 
  c_inv.vendor_id = i.vendor_id
  AND c_inv.invoice_num_base = 
  CASE SUBSTR(i.invoice_num, 1, 3)
    WHEN 'DCR' THEN SUBSTR(i.invoice_num,4,length(i.invoice_num)-3)
    WHEN 'DDR' THEN SUBSTR(i.invoice_num,4,length(i.invoice_num)-3)
    ELSE 
      CASE SUBSTR(i.invoice_num, LENGTH(i.invoice_num), 1)
      WHEN 'R' THEN SUBSTR(i.invoice_num, 1, length(i.invoice_num)-1)
      WHEN 'A' THEN SUBSTR(i.invoice_num, 1, length(i.invoice_num)-1)
      WHEN 'B' THEN SUBSTR(i.invoice_num, 1, length(i.invoice_num)-1)
      WHEN 'C' THEN SUBSTR(i.invoice_num, 1, length(i.invoice_num)-1)
      ELSE i.invoice_num
      END 
    END
ORDER BY 1
