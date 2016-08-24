/*
Author: David Chi
Date Created: 2016-07-01
Tableau Workbooks:
  T_and_E_YTD_YOY.twbx
 
Notes: Breaks down T&E expenses into Labels.
    Joins CY and PY.nrvifvjikrdckkrdjbnhdkvdvcvjijir
    
*/

SELECT

op.company
, op.cost_center
, op.vendor_id
, op.label
, op.month_transaction
, vendor.VENDOR_NAME
, comp.LEVEL0_DESCRIPTION
, comp.LEGAL_ENTITY
, NVL(cy_tec.amount_usd, 0) amount_usd_cy
, NVL(py_tec.amount_usd, 0) amount_usd_py

FROM

(
SELECT
company
, cost_center
, vendor_id
, label
, month_transaction
from
(
SELECT
DISTINCT
te.id_d_ebs_coa_company company
, te.id_d_ebs_coa_cost_center cost_center
, te.id_d_vendor vendor_id
, CASE LOWER(te.EXPENSE_TYPE)
  WHEN 'breakfast' THEN 'Benefit'
  WHEN 'breakfast - satellite offices only' THEN 'Benefit'
  WHEN 'dinner - satellite offices only' THEN 'Benefit'
  WHEN 'gym (uk only)' THEN 'Benefit'
  WHEN 'home to work travel (uk only)' THEN 'Benefit'
  WHEN 'laundry allowance (non mpk/mtv based employee)' THEN 'Benefit'
  WHEN 'lunch - satellite offices only' THEN 'Benefit'
  WHEN 'medical service plan (msp) canada only' THEN 'Benefit'
  WHEN 'other employee benefits' THEN 'Benefit'
  WHEN 'transportation benefit (non palo alto based employee)' THEN 'Benefit'
  WHEN 'breakfast (satellite offices only)' THEN 'Benefit'
  WHEN 'breakfast/lunch - satellite offices only' THEN 'Benefit'
  WHEN 'dinner (satellite offices only)' THEN 'Benefit'
  WHEN 'lunch (satellite offices only)' THEN 'Benefit'
  WHEN 'candidate only - hotel' THEN 'Candidate'
  WHEN 'candidate only - meals' THEN 'Candidate'
  WHEN 'candidate only - other' THEN 'Candidate'
  WHEN 'candidate only - transportation and parking' THEN 'Candidate'
  WHEN 'all other (candidate use only)' THEN 'Candidate'
  WHEN 'meals (candidate use only)' THEN 'Candidate'
  WHEN 'transportation (candidate use only)' THEN 'Candidate'
  WHEN 'hotel' THEN 'Hotel'
  WHEN 'hotel (legacy)' THEN 'Hotel'
  WHEN 'advertising' THEN 'Other Expenses'
  WHEN 'bike (intern only)' THEN 'Other Expenses'
  WHEN 'caltrain parking reimbursement' THEN 'Other Expenses'
  WHEN 'cellular phone  ' THEN 'Other Expenses'
  WHEN 'company event' THEN 'Other Expenses'
  WHEN 'conference/seminars/training' THEN 'Other Expenses'
  WHEN 'consultants' THEN 'Other Expenses'
  WHEN 'creative services' THEN 'Other Expenses'
  WHEN 'creative shop only - corporate card only' THEN 'Other Expenses'
  WHEN 'data center equipment repairs and maintenance' THEN 'Other Expenses'
  WHEN 'dues' THEN 'Other Expenses'
  WHEN 'education and training' THEN 'Other Expenses'
  WHEN 'email/monitoring services' THEN 'Other Expenses'
  WHEN 'employee ads dogfooding' THEN 'Other Expenses'
  WHEN 'employee swag' THEN 'Other Expenses'
  WHEN 'entertainment - employees/non-employees' THEN 'Other Expenses'
  WHEN 'equipment - < $1k' THEN 'Other Expenses'
  WHEN 'equipment r' || chr(38) || 'd' THEN 'Other Expenses'
  WHEN 'equipment rental and leases' THEN 'Other Expenses'
  WHEN 'equipment repairs and maintenance' THEN 'Other Expenses'
  WHEN 'facility move costs' THEN 'Other Expenses'
  WHEN 'facility professional services' THEN 'Other Expenses'
  WHEN 'facility repairs and maintenance' THEN 'Other Expenses'
  WHEN 'gifts' THEN 'Other Expenses'
  WHEN 'gifts to customers' THEN 'Other Expenses'
  WHEN 'gifts to employees' THEN 'Other Expenses'
  WHEN 'government stamp duty fee' THEN 'Other Expenses'
  WHEN 'infra dc r' || chr(38) || 'd/design' THEN 'Other Expenses'
  WHEN 'intern relocation (intern only)' THEN 'Other Expenses'
  WHEN 'internet' THEN 'Other Expenses'
  WHEN 'kitchen' THEN 'Other Expenses'
  WHEN 'kitchen contractor' THEN 'Other Expenses'
  WHEN 'kitchen supplies and vending' THEN 'Other Expenses'
  WHEN 'local phone' THEN 'Other Expenses'
  WHEN 'long distance' THEN 'Other Expenses'
  WHEN 'manager offsite' THEN 'Other Expenses'
  WHEN 'market research' THEN 'Other Expenses'
  WHEN 'marketing events (dev gar, f8, etc.)' THEN 'Other Expenses'
  WHEN 'marketing materials' THEN 'Other Expenses'
  WHEN 'meals - employees/non-employees' THEN 'Other Expenses'
  WHEN 'mileage (intern only)' THEN 'Other Expenses'
  WHEN 'misc. promotional expense  ' THEN 'Other Expenses'
  WHEN 'mobile marketing' THEN 'Other Expenses'
  WHEN 'office supplies' THEN 'Other Expenses'
  WHEN 'office supplies and printing' THEN 'Other Expenses'
  WHEN 'online fees  ' THEN 'Other Expenses'
  WHEN 'other employee meals' THEN 'Other Expenses'
  WHEN 'other marketing' THEN 'Other Expenses'
  WHEN 'postage/freight' THEN 'Other Expenses'
  WHEN 'professional dues' THEN 'Other Expenses'
  WHEN 'professional dues and subscriptions' THEN 'Other Expenses'
  WHEN 'professional services' THEN 'Other Expenses'
  WHEN 'professional services other' THEN 'Other Expenses'
  WHEN 'professional subscriptions' THEN 'Other Expenses'
  WHEN 'public relations' THEN 'Other Expenses'
  WHEN 'recruiting - job postings, etc.' THEN 'Other Expenses'
  WHEN 'recruiting other' THEN 'Other Expenses'
  WHEN 'sales meetings' THEN 'Other Expenses'
  WHEN 'search firm' THEN 'Other Expenses'
  WHEN 'seminars/conference fees' THEN 'Other Expenses'
  WHEN 'shipping (intern only)' THEN 'Other Expenses'
  WHEN 'software < $1k' THEN 'Other Expenses'
  WHEN 'software license' THEN 'Other Expenses'
  WHEN 'taxes and licenses' THEN 'Other Expenses'
  WHEN 'taxis (intern only)' THEN 'Other Expenses'
  WHEN 'team/group offsites' THEN 'Other Expenses'
  WHEN 'technology licenses' THEN 'Other Expenses'
  WHEN 'telephone - cellular phone' THEN 'Other Expenses'
  WHEN 'temporary services' THEN 'Other Expenses'
  WHEN 'trade shows  ' THEN 'Other Expenses'
  WHEN 'utilities' THEN 'Other Expenses'
  WHEN 'vending' THEN 'Other Expenses'
  WHEN 'white hat bug bounty' THEN 'Other Expenses'
  WHEN 'awards' THEN 'Other Expenses'
  WHEN 'charitable donations (do not use)' THEN 'Other Expenses'
  WHEN 'conference/seminars' THEN 'Other Expenses'
  WHEN 'corporate card: rewards fees and rush shipping' THEN 'Other Expenses'
  WHEN 'duplicating' THEN 'Other Expenses'
  WHEN 'entertainment - employees' THEN 'Other Expenses'
  WHEN 'entertainment - non-employees' THEN 'Other Expenses'
  WHEN 'equipment' THEN 'Other Expenses'
  WHEN 'gifts to government officials' THEN 'Other Expenses'
  WHEN 'group offsites' THEN 'Other Expenses'
  WHEN 'guest travel' THEN 'Other Expenses'
  WHEN 'gyms' THEN 'Other Expenses'
  WHEN 'intern relocation (intern use only)' THEN 'Other Expenses'
  WHEN 'internet service ' THEN 'Other Expenses'
  WHEN 'ktichen supplies and vending' THEN 'Other Expenses'
  WHEN 'laundry allowance (non mpk based employee)' THEN 'Other Expenses'
  WHEN 'laundry allowance (non palo alto based employee)' THEN 'Other Expenses'
  WHEN 'marketing events' THEN 'Other Expenses'
  WHEN 'pager' THEN 'Other Expenses'
  WHEN 'political contribution - do not use - ' THEN 'Other Expenses'
  WHEN 'rewards fee' THEN 'Other Expenses'
  WHEN 'software' THEN 'Other Expenses'
  WHEN 'training' THEN 'Other Expenses'
  WHEN 'uncategorized expenses' THEN 'Other Expenses'
  WHEN 'valuation services' THEN 'Other Expenses'
  WHEN 'airfare/baggage fees' THEN 'Airline'
  WHEN 'baggage fees' THEN 'Airline'
  WHEN 'car rental/taxi/bus/train/gas for rental' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry/tsa pre' THEN 'T' || chr(38) || 'E'
  WHEN 'corporate card: fees and rush shipping' THEN 'T' || chr(38) || 'E'
  WHEN 'dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'fx/visa/passport fees/inoculation' THEN 'T' || chr(38) || 'E'
  WHEN 'gasoline' THEN 'T' || chr(38) || 'E'
  WHEN 'laundry (travel only)' THEN 'T' || chr(38) || 'E'
  WHEN 'lunch' THEN 'T' || chr(38) || 'E'
  WHEN 'mileage' THEN 'T' || chr(38) || 'E'
  WHEN 'parking/tolls/street meter' THEN 'T' || chr(38) || 'E'
  WHEN 'personal car mileage' THEN 'T' || chr(38) || 'E'
  WHEN 'personal expense' THEN 'T' || chr(38) || 'E'
  WHEN 'shuttle/bus service' THEN 'T' || chr(38) || 'E'
  WHEN 'taxi' THEN 'T' || chr(38) || 'E'
  WHEN 'telephone - hotel' THEN 'T' || chr(38) || 'E'
  WHEN 'tips' THEN 'T' || chr(38) || 'E'
  WHEN 'train/bus/subway' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - breakfast' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - lunch' THEN 'T' || chr(38) || 'E'
  WHEN 'travel meals - breakfast/lunch/dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'airfare' THEN 'Airline'
  WHEN 'airline baggage fees / seat assignment / etc' THEN 'Airline'
  WHEN 'bus' THEN 'T' || chr(38) || 'E'
  WHEN 'car rental' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry fee' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry/reward fee' THEN 'T' || chr(38) || 'E'
  WHEN 'foreign transaction fees' THEN 'T' || chr(38) || 'E'
  WHEN 'fx/visa/passport fees' THEN 'T' || chr(38) || 'E'
  WHEN 'rail' THEN 'T' || chr(38) || 'E'
  WHEN 'subway' THEN 'T' || chr(38) || 'E'
  WHEN 'tolls' THEN 'T' || chr(38) || 'E'
  WHEN 'train' THEN 'T' || chr(38) || 'E'
  WHEN 'travel meals (breakfast/lunch/dinner)' THEN 'T' || chr(38) || 'E'
  WHEN 'visa/passport services' THEN 'T' || chr(38) || 'E'
  WHEN 'gas/petrol for rental car' THEN 'T' || chr(38) || 'E'
  WHEN 'parking' THEN 'T' || chr(38) || 'E'
  WHEN 'parking - street meters' THEN 'T' || chr(38) || 'E'
  ELSE 'Unclassified Expenses'
  END LABEL
from OBIAW_PRD.F_TRAVEL_EXPENSES te
WHERE te.id_d_date_transaction > SYSDATE - 750
) vendor_label
CROSS JOIN
(
SELECT
DISTINCT TRUNC(te.id_d_date_transaction, 'month') month_transaction
from OBIAW_PRD.F_TRAVEL_EXPENSES te
WHERE te.id_d_date_transaction > SYSDATE - 1000
AND te.id_d_date_transaction <= SYSDATE
ORDER BY 1
) cy_month
) op

LEFT JOIN
(
SELECT
te.id_d_vendor
, te.id_d_ebs_coa_company
, te.id_d_ebs_coa_cost_center
, month_transaction
, LABEL
, SUM(te.amount_usd) amount_usd
FROM
(SELECT
te.id_d_ebs_coa_company
, te.id_d_ebs_coa_cost_center
, te.id_d_vendor
, TRUNC(te.id_d_date_transaction, 'month') month_transaction
, CASE LOWER(te.EXPENSE_TYPE)
  WHEN 'breakfast' THEN 'Benefit'
  WHEN 'breakfast - satellite offices only' THEN 'Benefit'
  WHEN 'dinner - satellite offices only' THEN 'Benefit'
  WHEN 'gym (uk only)' THEN 'Benefit'
  WHEN 'home to work travel (uk only)' THEN 'Benefit'
  WHEN 'laundry allowance (non mpk/mtv based employee)' THEN 'Benefit'
  WHEN 'lunch - satellite offices only' THEN 'Benefit'
  WHEN 'medical service plan (msp) canada only' THEN 'Benefit'
  WHEN 'other employee benefits' THEN 'Benefit'
  WHEN 'transportation benefit (non palo alto based employee)' THEN 'Benefit'
  WHEN 'breakfast (satellite offices only)' THEN 'Benefit'
  WHEN 'breakfast/lunch - satellite offices only' THEN 'Benefit'
  WHEN 'dinner (satellite offices only)' THEN 'Benefit'
  WHEN 'lunch (satellite offices only)' THEN 'Benefit'
  WHEN 'candidate only - hotel' THEN 'Candidate'
  WHEN 'candidate only - meals' THEN 'Candidate'
  WHEN 'candidate only - other' THEN 'Candidate'
  WHEN 'candidate only - transportation and parking' THEN 'Candidate'
  WHEN 'all other (candidate use only)' THEN 'Candidate'
  WHEN 'meals (candidate use only)' THEN 'Candidate'
  WHEN 'transportation (candidate use only)' THEN 'Candidate'
  WHEN 'hotel' THEN 'Hotel'
  WHEN 'hotel (legacy)' THEN 'Hotel'
  WHEN 'advertising' THEN 'Other Expenses'
  WHEN 'bike (intern only)' THEN 'Other Expenses'
  WHEN 'caltrain parking reimbursement' THEN 'Other Expenses'
  WHEN 'cellular phone  ' THEN 'Other Expenses'
  WHEN 'company event' THEN 'Other Expenses'
  WHEN 'conference/seminars/training' THEN 'Other Expenses'
  WHEN 'consultants' THEN 'Other Expenses'
  WHEN 'creative services' THEN 'Other Expenses'
  WHEN 'creative shop only - corporate card only' THEN 'Other Expenses'
  WHEN 'data center equipment repairs and maintenance' THEN 'Other Expenses'
  WHEN 'dues' THEN 'Other Expenses'
  WHEN 'education and training' THEN 'Other Expenses'
  WHEN 'email/monitoring services' THEN 'Other Expenses'
  WHEN 'employee ads dogfooding' THEN 'Other Expenses'
  WHEN 'employee swag' THEN 'Other Expenses'
  WHEN 'entertainment - employees/non-employees' THEN 'Other Expenses'
  WHEN 'equipment - < $1k' THEN 'Other Expenses'
  WHEN 'equipment r' || chr(38) || 'd' THEN 'Other Expenses'
  WHEN 'equipment rental and leases' THEN 'Other Expenses'
  WHEN 'equipment repairs and maintenance' THEN 'Other Expenses'
  WHEN 'facility move costs' THEN 'Other Expenses'
  WHEN 'facility professional services' THEN 'Other Expenses'
  WHEN 'facility repairs and maintenance' THEN 'Other Expenses'
  WHEN 'gifts' THEN 'Other Expenses'
  WHEN 'gifts to customers' THEN 'Other Expenses'
  WHEN 'gifts to employees' THEN 'Other Expenses'
  WHEN 'government stamp duty fee' THEN 'Other Expenses'
  WHEN 'infra dc r' || chr(38) || 'd/design' THEN 'Other Expenses'
  WHEN 'intern relocation (intern only)' THEN 'Other Expenses'
  WHEN 'internet' THEN 'Other Expenses'
  WHEN 'kitchen' THEN 'Other Expenses'
  WHEN 'kitchen contractor' THEN 'Other Expenses'
  WHEN 'kitchen supplies and vending' THEN 'Other Expenses'
  WHEN 'local phone' THEN 'Other Expenses'
  WHEN 'long distance' THEN 'Other Expenses'
  WHEN 'manager offsite' THEN 'Other Expenses'
  WHEN 'market research' THEN 'Other Expenses'
  WHEN 'marketing events (dev gar, f8, etc.)' THEN 'Other Expenses'
  WHEN 'marketing materials' THEN 'Other Expenses'
  WHEN 'meals - employees/non-employees' THEN 'Other Expenses'
  WHEN 'mileage (intern only)' THEN 'Other Expenses'
  WHEN 'misc. promotional expense  ' THEN 'Other Expenses'
  WHEN 'mobile marketing' THEN 'Other Expenses'
  WHEN 'office supplies' THEN 'Other Expenses'
  WHEN 'office supplies and printing' THEN 'Other Expenses'
  WHEN 'online fees  ' THEN 'Other Expenses'
  WHEN 'other employee meals' THEN 'Other Expenses'
  WHEN 'other marketing' THEN 'Other Expenses'
  WHEN 'postage/freight' THEN 'Other Expenses'
  WHEN 'professional dues' THEN 'Other Expenses'
  WHEN 'professional dues and subscriptions' THEN 'Other Expenses'
  WHEN 'professional services' THEN 'Other Expenses'
  WHEN 'professional services other' THEN 'Other Expenses'
  WHEN 'professional subscriptions' THEN 'Other Expenses'
  WHEN 'public relations' THEN 'Other Expenses'
  WHEN 'recruiting - job postings, etc.' THEN 'Other Expenses'
  WHEN 'recruiting other' THEN 'Other Expenses'
  WHEN 'sales meetings' THEN 'Other Expenses'
  WHEN 'search firm' THEN 'Other Expenses'
  WHEN 'seminars/conference fees' THEN 'Other Expenses'
  WHEN 'shipping (intern only)' THEN 'Other Expenses'
  WHEN 'software < $1k' THEN 'Other Expenses'
  WHEN 'software license' THEN 'Other Expenses'
  WHEN 'taxes and licenses' THEN 'Other Expenses'
  WHEN 'taxis (intern only)' THEN 'Other Expenses'
  WHEN 'team/group offsites' THEN 'Other Expenses'
  WHEN 'technology licenses' THEN 'Other Expenses'
  WHEN 'telephone - cellular phone' THEN 'Other Expenses'
  WHEN 'temporary services' THEN 'Other Expenses'
  WHEN 'trade shows  ' THEN 'Other Expenses'
  WHEN 'utilities' THEN 'Other Expenses'
  WHEN 'vending' THEN 'Other Expenses'
  WHEN 'white hat bug bounty' THEN 'Other Expenses'
  WHEN 'awards' THEN 'Other Expenses'
  WHEN 'charitable donations (do not use)' THEN 'Other Expenses'
  WHEN 'conference/seminars' THEN 'Other Expenses'
  WHEN 'corporate card: rewards fees and rush shipping' THEN 'Other Expenses'
  WHEN 'duplicating' THEN 'Other Expenses'
  WHEN 'entertainment - employees' THEN 'Other Expenses'
  WHEN 'entertainment - non-employees' THEN 'Other Expenses'
  WHEN 'equipment' THEN 'Other Expenses'
  WHEN 'gifts to government officials' THEN 'Other Expenses'
  WHEN 'group offsites' THEN 'Other Expenses'
  WHEN 'guest travel' THEN 'Other Expenses'
  WHEN 'gyms' THEN 'Other Expenses'
  WHEN 'intern relocation (intern use only)' THEN 'Other Expenses'
  WHEN 'internet service ' THEN 'Other Expenses'
  WHEN 'ktichen supplies and vending' THEN 'Other Expenses'
  WHEN 'laundry allowance (non mpk based employee)' THEN 'Other Expenses'
  WHEN 'laundry allowance (non palo alto based employee)' THEN 'Other Expenses'
  WHEN 'marketing events' THEN 'Other Expenses'
  WHEN 'pager' THEN 'Other Expenses'
  WHEN 'political contribution - do not use - ' THEN 'Other Expenses'
  WHEN 'rewards fee' THEN 'Other Expenses'
  WHEN 'software' THEN 'Other Expenses'
  WHEN 'training' THEN 'Other Expenses'
  WHEN 'uncategorized expenses' THEN 'Other Expenses'
  WHEN 'valuation services' THEN 'Other Expenses'
  WHEN 'airfare/baggage fees' THEN 'Airline'
  WHEN 'baggage fees' THEN 'Airline'
  WHEN 'car rental/taxi/bus/train/gas for rental' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry/tsa pre' THEN 'T' || chr(38) || 'E'
  WHEN 'corporate card: fees and rush shipping' THEN 'T' || chr(38) || 'E'
  WHEN 'dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'fx/visa/passport fees/inoculation' THEN 'T' || chr(38) || 'E'
  WHEN 'gasoline' THEN 'T' || chr(38) || 'E'
  WHEN 'laundry (travel only)' THEN 'T' || chr(38) || 'E'
  WHEN 'lunch' THEN 'T' || chr(38) || 'E'
  WHEN 'mileage' THEN 'T' || chr(38) || 'E'
  WHEN 'parking/tolls/street meter' THEN 'T' || chr(38) || 'E'
  WHEN 'personal car mileage' THEN 'T' || chr(38) || 'E'
  WHEN 'personal expense' THEN 'T' || chr(38) || 'E'
  WHEN 'shuttle/bus service' THEN 'T' || chr(38) || 'E'
  WHEN 'taxi' THEN 'T' || chr(38) || 'E'
  WHEN 'telephone - hotel' THEN 'T' || chr(38) || 'E'
  WHEN 'tips' THEN 'T' || chr(38) || 'E'
  WHEN 'train/bus/subway' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - breakfast' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - lunch' THEN 'T' || chr(38) || 'E'
  WHEN 'travel meals - breakfast/lunch/dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'airfare' THEN 'Airline'
  WHEN 'airline baggage fees / seat assignment / etc' THEN 'Airline'
  WHEN 'bus' THEN 'T' || chr(38) || 'E'
  WHEN 'car rental' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry fee' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry/reward fee' THEN 'T' || chr(38) || 'E'
  WHEN 'foreign transaction fees' THEN 'T' || chr(38) || 'E'
  WHEN 'fx/visa/passport fees' THEN 'T' || chr(38) || 'E'
  WHEN 'rail' THEN 'T' || chr(38) || 'E'
  WHEN 'subway' THEN 'T' || chr(38) || 'E'
  WHEN 'tolls' THEN 'T' || chr(38) || 'E'
  WHEN 'train' THEN 'T' || chr(38) || 'E'
  WHEN 'travel meals (breakfast/lunch/dinner)' THEN 'T' || chr(38) || 'E'
  WHEN 'visa/passport services' THEN 'T' || chr(38) || 'E'
  WHEN 'gas/petrol for rental car' THEN 'T' || chr(38) || 'E'
  WHEN 'parking' THEN 'T' || chr(38) || 'E'
  WHEN 'parking - street meters' THEN 'T' || chr(38) || 'E'
  ELSE 'Unclassified Expenses'
  END label
, te.amount_usd
from OBIAW_PRD.F_TRAVEL_EXPENSES te
WHERE te.id_d_date_transaction >= SYSDATE - 1000) te
GROUP BY
id_d_ebs_coa_company, id_d_ebs_coa_cost_center, id_d_vendor, month_transaction, label
) cy_tec
  ON op.company = cy_tec.id_d_ebs_coa_company
  AND op.cost_center = cy_tec.id_d_ebs_coa_cost_center
  AND op.vendor_id = cy_tec.id_d_vendor
  AND op.label = cy_tec.label
  AND op.month_transaction = cy_tec.month_transaction

LEFT JOIN
(
SELECT
te.id_d_vendor
, te.id_d_ebs_coa_company
, te.id_d_ebs_coa_cost_center
, month_transaction
, LABEL
, SUM(te.amount_usd) amount_usd
FROM
(SELECT
te.id_d_ebs_coa_company
, te.id_d_ebs_coa_cost_center
, te.id_d_vendor
, TRUNC(te.id_d_date_transaction, 'month') month_transaction
, CASE LOWER(te.EXPENSE_TYPE)
  WHEN 'breakfast' THEN 'Benefit'
  WHEN 'breakfast - satellite offices only' THEN 'Benefit'
  WHEN 'dinner - satellite offices only' THEN 'Benefit'
  WHEN 'gym (uk only)' THEN 'Benefit'
  WHEN 'home to work travel (uk only)' THEN 'Benefit'
  WHEN 'laundry allowance (non mpk/mtv based employee)' THEN 'Benefit'
  WHEN 'lunch - satellite offices only' THEN 'Benefit'
  WHEN 'medical service plan (msp) canada only' THEN 'Benefit'
  WHEN 'other employee benefits' THEN 'Benefit'
  WHEN 'transportation benefit (non palo alto based employee)' THEN 'Benefit'
  WHEN 'breakfast (satellite offices only)' THEN 'Benefit'
  WHEN 'breakfast/lunch - satellite offices only' THEN 'Benefit'
  WHEN 'dinner (satellite offices only)' THEN 'Benefit'
  WHEN 'lunch (satellite offices only)' THEN 'Benefit'
  WHEN 'candidate only - hotel' THEN 'Candidate'
  WHEN 'candidate only - meals' THEN 'Candidate'
  WHEN 'candidate only - other' THEN 'Candidate'
  WHEN 'candidate only - transportation and parking' THEN 'Candidate'
  WHEN 'all other (candidate use only)' THEN 'Candidate'
  WHEN 'meals (candidate use only)' THEN 'Candidate'
  WHEN 'transportation (candidate use only)' THEN 'Candidate'
  WHEN 'hotel' THEN 'Hotel'
  WHEN 'hotel (legacy)' THEN 'Hotel'
  WHEN 'advertising' THEN 'Other Expenses'
  WHEN 'bike (intern only)' THEN 'Other Expenses'
  WHEN 'caltrain parking reimbursement' THEN 'Other Expenses'
  WHEN 'cellular phone  ' THEN 'Other Expenses'
  WHEN 'company event' THEN 'Other Expenses'
  WHEN 'conference/seminars/training' THEN 'Other Expenses'
  WHEN 'consultants' THEN 'Other Expenses'
  WHEN 'creative services' THEN 'Other Expenses'
  WHEN 'creative shop only - corporate card only' THEN 'Other Expenses'
  WHEN 'data center equipment repairs and maintenance' THEN 'Other Expenses'
  WHEN 'dues' THEN 'Other Expenses'
  WHEN 'education and training' THEN 'Other Expenses'
  WHEN 'email/monitoring services' THEN 'Other Expenses'
  WHEN 'employee ads dogfooding' THEN 'Other Expenses'
  WHEN 'employee swag' THEN 'Other Expenses'
  WHEN 'entertainment - employees/non-employees' THEN 'Other Expenses'
  WHEN 'equipment - < $1k' THEN 'Other Expenses'
  WHEN 'equipment r' || chr(38) || 'd' THEN 'Other Expenses'
  WHEN 'equipment rental and leases' THEN 'Other Expenses'
  WHEN 'equipment repairs and maintenance' THEN 'Other Expenses'
  WHEN 'facility move costs' THEN 'Other Expenses'
  WHEN 'facility professional services' THEN 'Other Expenses'
  WHEN 'facility repairs and maintenance' THEN 'Other Expenses'
  WHEN 'gifts' THEN 'Other Expenses'
  WHEN 'gifts to customers' THEN 'Other Expenses'
  WHEN 'gifts to employees' THEN 'Other Expenses'
  WHEN 'government stamp duty fee' THEN 'Other Expenses'
  WHEN 'infra dc r' || chr(38) || 'd/design' THEN 'Other Expenses'
  WHEN 'intern relocation (intern only)' THEN 'Other Expenses'
  WHEN 'internet' THEN 'Other Expenses'
  WHEN 'kitchen' THEN 'Other Expenses'
  WHEN 'kitchen contractor' THEN 'Other Expenses'
  WHEN 'kitchen supplies and vending' THEN 'Other Expenses'
  WHEN 'local phone' THEN 'Other Expenses'
  WHEN 'long distance' THEN 'Other Expenses'
  WHEN 'manager offsite' THEN 'Other Expenses'
  WHEN 'market research' THEN 'Other Expenses'
  WHEN 'marketing events (dev gar, f8, etc.)' THEN 'Other Expenses'
  WHEN 'marketing materials' THEN 'Other Expenses'
  WHEN 'meals - employees/non-employees' THEN 'Other Expenses'
  WHEN 'mileage (intern only)' THEN 'Other Expenses'
  WHEN 'misc. promotional expense  ' THEN 'Other Expenses'
  WHEN 'mobile marketing' THEN 'Other Expenses'
  WHEN 'office supplies' THEN 'Other Expenses'
  WHEN 'office supplies and printing' THEN 'Other Expenses'
  WHEN 'online fees  ' THEN 'Other Expenses'
  WHEN 'other employee meals' THEN 'Other Expenses'
  WHEN 'other marketing' THEN 'Other Expenses'
  WHEN 'postage/freight' THEN 'Other Expenses'
  WHEN 'professional dues' THEN 'Other Expenses'
  WHEN 'professional dues and subscriptions' THEN 'Other Expenses'
  WHEN 'professional services' THEN 'Other Expenses'
  WHEN 'professional services other' THEN 'Other Expenses'
  WHEN 'professional subscriptions' THEN 'Other Expenses'
  WHEN 'public relations' THEN 'Other Expenses'
  WHEN 'recruiting - job postings, etc.' THEN 'Other Expenses'
  WHEN 'recruiting other' THEN 'Other Expenses'
  WHEN 'sales meetings' THEN 'Other Expenses'
  WHEN 'search firm' THEN 'Other Expenses'
  WHEN 'seminars/conference fees' THEN 'Other Expenses'
  WHEN 'shipping (intern only)' THEN 'Other Expenses'
  WHEN 'software < $1k' THEN 'Other Expenses'
  WHEN 'software license' THEN 'Other Expenses'
  WHEN 'taxes and licenses' THEN 'Other Expenses'
  WHEN 'taxis (intern only)' THEN 'Other Expenses'
  WHEN 'team/group offsites' THEN 'Other Expenses'
  WHEN 'technology licenses' THEN 'Other Expenses'
  WHEN 'telephone - cellular phone' THEN 'Other Expenses'
  WHEN 'temporary services' THEN 'Other Expenses'
  WHEN 'trade shows  ' THEN 'Other Expenses'
  WHEN 'utilities' THEN 'Other Expenses'
  WHEN 'vending' THEN 'Other Expenses'
  WHEN 'white hat bug bounty' THEN 'Other Expenses'
  WHEN 'awards' THEN 'Other Expenses'
  WHEN 'charitable donations (do not use)' THEN 'Other Expenses'
  WHEN 'conference/seminars' THEN 'Other Expenses'
  WHEN 'corporate card: rewards fees and rush shipping' THEN 'Other Expenses'
  WHEN 'duplicating' THEN 'Other Expenses'
  WHEN 'entertainment - employees' THEN 'Other Expenses'
  WHEN 'entertainment - non-employees' THEN 'Other Expenses'
  WHEN 'equipment' THEN 'Other Expenses'
  WHEN 'gifts to government officials' THEN 'Other Expenses'
  WHEN 'group offsites' THEN 'Other Expenses'
  WHEN 'guest travel' THEN 'Other Expenses'
  WHEN 'gyms' THEN 'Other Expenses'
  WHEN 'intern relocation (intern use only)' THEN 'Other Expenses'
  WHEN 'internet service ' THEN 'Other Expenses'
  WHEN 'ktichen supplies and vending' THEN 'Other Expenses'
  WHEN 'laundry allowance (non mpk based employee)' THEN 'Other Expenses'
  WHEN 'laundry allowance (non palo alto based employee)' THEN 'Other Expenses'
  WHEN 'marketing events' THEN 'Other Expenses'
  WHEN 'pager' THEN 'Other Expenses'
  WHEN 'political contribution - do not use - ' THEN 'Other Expenses'
  WHEN 'rewards fee' THEN 'Other Expenses'
  WHEN 'software' THEN 'Other Expenses'
  WHEN 'training' THEN 'Other Expenses'
  WHEN 'uncategorized expenses' THEN 'Other Expenses'
  WHEN 'valuation services' THEN 'Other Expenses'
  WHEN 'airfare/baggage fees' THEN 'Airline'
  WHEN 'baggage fees' THEN 'Airline'
  WHEN 'car rental/taxi/bus/train/gas for rental' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry/tsa pre' THEN 'T' || chr(38) || 'E'
  WHEN 'corporate card: fees and rush shipping' THEN 'T' || chr(38) || 'E'
  WHEN 'dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'fx/visa/passport fees/inoculation' THEN 'T' || chr(38) || 'E'
  WHEN 'gasoline' THEN 'T' || chr(38) || 'E'
  WHEN 'laundry (travel only)' THEN 'T' || chr(38) || 'E'
  WHEN 'lunch' THEN 'T' || chr(38) || 'E'
  WHEN 'mileage' THEN 'T' || chr(38) || 'E'
  WHEN 'parking/tolls/street meter' THEN 'T' || chr(38) || 'E'
  WHEN 'personal car mileage' THEN 'T' || chr(38) || 'E'
  WHEN 'personal expense' THEN 'T' || chr(38) || 'E'
  WHEN 'shuttle/bus service' THEN 'T' || chr(38) || 'E'
  WHEN 'taxi' THEN 'T' || chr(38) || 'E'
  WHEN 'telephone - hotel' THEN 'T' || chr(38) || 'E'
  WHEN 'tips' THEN 'T' || chr(38) || 'E'
  WHEN 'train/bus/subway' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - breakfast' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'travel - lunch' THEN 'T' || chr(38) || 'E'
  WHEN 'travel meals - breakfast/lunch/dinner' THEN 'T' || chr(38) || 'E'
  WHEN 'airfare' THEN 'Airline'
  WHEN 'airline baggage fees / seat assignment / etc' THEN 'Airline'
  WHEN 'bus' THEN 'T' || chr(38) || 'E'
  WHEN 'car rental' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry fee' THEN 'T' || chr(38) || 'E'
  WHEN 'clear/global entry/reward fee' THEN 'T' || chr(38) || 'E'
  WHEN 'foreign transaction fees' THEN 'T' || chr(38) || 'E'
  WHEN 'fx/visa/passport fees' THEN 'T' || chr(38) || 'E'
  WHEN 'rail' THEN 'T' || chr(38) || 'E'
  WHEN 'subway' THEN 'T' || chr(38) || 'E'
  WHEN 'tolls' THEN 'T' || chr(38) || 'E'
  WHEN 'train' THEN 'T' || chr(38) || 'E'
  WHEN 'travel meals (breakfast/lunch/dinner)' THEN 'T' || chr(38) || 'E'
  WHEN 'visa/passport services' THEN 'T' || chr(38) || 'E'
  WHEN 'gas/petrol for rental car' THEN 'T' || chr(38) || 'E'
  WHEN 'parking' THEN 'T' || chr(38) || 'E'
  WHEN 'parking - street meters' THEN 'T' || chr(38) || 'E'
  ELSE 'Unclassified Expenses'
  END label
, te.amount_usd
from OBIAW_PRD.F_TRAVEL_EXPENSES te
WHERE te.id_d_date_transaction >= SYSDATE - 1000
AND te.id_d_date_transaction < SYSDATE - 365
) te
GROUP BY
id_d_ebs_coa_company, id_d_ebs_coa_cost_center, id_d_vendor, month_transaction, label
) py_tec
  ON op.company = py_tec.id_d_ebs_coa_company
  AND op.cost_center = py_tec.id_d_ebs_coa_cost_center
  AND op.vendor_id = py_tec.id_d_vendor
  AND op.label = py_tec.label
  AND EXTRACT(month FROM op.month_transaction) = EXTRACT(month FROM py_tec.month_transaction)
  AND EXTRACT(year FROM op.month_transaction) = EXTRACT(year FROM py_tec.month_transaction) + 1

LEFT JOIN OBIAW_PRD.D_VENDOR_TRAVEL_EXPENSE vendor
  ON op.company = vendor.ID_D_VENDOR_TRAVEL_EXPENSE

LEFT JOIN OBIAW_PRD.D_EBS_COA_COMPANY comp
  ON op.company = comp.id_d_ebs_coa_company