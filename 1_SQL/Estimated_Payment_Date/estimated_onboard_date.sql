SELECT
request_id

, GREATEST(
 latest_date
 +
 CASE current_step
 WHEN 1 THEN 14
 WHEN 2 THEN 12.5
 WHEN 3 THEN 12
 WHEN 4 THEN 11.5
 WHEN 5 THEN 11
 WHEN 6 THEN 10
 WHEN 7 THEN 6
 WHEN 8 THEN 4.5
 WHEN 9 THEN 4
 WHEN 10 THEN 2
 WHEN 11 THEN 0
 ELSE 0 END
 , SYSDATE + (SYSDATE - latest_date)) AS ESTIMATED_ONBOARD_DATE

, 0 AS ML_VERSION
, SYSDATE AS CREATED_DATE 
, 216575 AS CREATED_BY
, SYSDATE AS LAST_UPDATED_DATE
, 216575 AS LAST_UPDATED_BY

FROM

(
select 
xia.request_id

, case
      when step11.creation_date is not null then 11
      when step10.creation_date is not null then 10
      when step9.creation_date is not null then 9
      when step8.creation_date is not null then 8
      when step7.creation_date is not null then 7
      when step6.creation_date is not null then 6
      when step5.creation_date is not null then 5
      when step4.creation_date is not null then 4
      when step3.creation_date is not null then 3
      when step2.creation_date is not null then 2
      when step1.creation_date is not null then 1 end as current_step

, case
      when step11.creation_date is not null then step11.creation_date
      when step10.creation_date is not null then step10.creation_date
      when step9.creation_date is not null then step9.creation_date
      when step8.creation_date is not null then step8.creation_date
      when step7.creation_date is not null then step7.creation_date
      when step6.creation_date is not null then step6.creation_date
      when step5.creation_date is not null then step5.creation_date
      when step4.creation_date is not null then step4.creation_date
      when step3.creation_date is not null then step3.creation_date
      when step2.creation_date is not null then step2.creation_date
      when step1.creation_date is not null then step1.creation_date end as latest_date
      
, case
      when step11.creation_date is not null then step11.creation_date-step1.creation_date
      when step10.creation_date is not null then step10.creation_date-step1.creation_date
      when step9.creation_date is not null then step9.creation_date-step1.creation_date
      when step8.creation_date is not null then step8.creation_date-step1.creation_date
      when step7.creation_date is not null then step7.creation_date-step1.creation_date
      when step6.creation_date is not null then step6.creation_date-step1.creation_date
      when step5.creation_date is not null then step5.creation_date-step1.creation_date
      when step4.creation_date is not null then step4.creation_date-step1.creation_date
      when step3.creation_date is not null then step3.creation_date-step1.creation_date
      when step2.creation_date is not null then step2.creation_date-step1.creation_date
      when step1.creation_date is not null then 0 end as time_elapsed

, CASE
   WHEN xia.status = 'NEW' THEN
     (CASE
        WHEN TRUNC ( xia.expiry_time) < TRUNC ( SYSDATE) THEN 'EXPIRED'
        WHEN psr.registration_status = 'REQ_FOR_INFO' THEN 'REQ_FOR_INFO'
        ELSE 'INVITED'
      END)
   WHEN xia.status = 'SUBMITTED' THEN psr.registration_status
   ELSE xia.status
 END
   reg_status_code
,u.description full_user_name, u.user_name

from xxfb.xxfb_ap_isupplier_register xia,xxfb.xxfb_ap_supreg_general_info xas, apps.hr_all_organization_units hou, apps.pos_supplier_registrations psr, apps.fnd_user u
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='INVITED_SUPPLIER' group by request_id )step1
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='ACCESSED_ENROLLMENT' group by request_id )step2
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='UPDATED_COMP_INFO' group by request_id )step3
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='UPDATED_BANK_INFO' group by request_id )step4
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='REQ_SUBMITTED' group by request_id )step5
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='RDC_CHECK_COMPLETED' group by request_id )step6
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='FCPA_APPROVED' group by request_id )step7
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='PROU_APPROVED' group by request_id )step8
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='SUPPLIER_RFI' group by request_id )step9
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='PHD_APPROVED' group by request_id )step10
  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='POS_REQUEST_APPROVED' group by request_id )step11

  ,(select request_id, min(creation_date) creation_date from apps.xxfb_ap_supreg_action_history where action_code='WITHDRAWN' group by request_id )stepX
  -- goal is to get infra vendors
  ,(
      select reg2.request_id, p.vendor_id, case when sum(case when cc.segment2 in ('4110','4220','4310','4320','4330','4340','4350','4360','4390','5546') then 1 else 0 end) > 1 then 'Infra' else 'Non-infra' end po_infra_flag
      from apps.po_headers_all p, apps.po_distributions_all pd, apps.gl_code_combinations cc
        , apps.pos_supplier_registrations reg, xxfb.xxfb_ap_isupplier_register reg2
      where pd.code_combination_id=cc.code_combination_id and p.po_header_id=pd.po_header_id
      and reg.po_vendor_id=p.vendor_id and reg.supplier_reg_id=reg2.supplier_reg_id
      group by p.vendor_id, reg2.request_id
  ) infra_po
  -- goal is to get infra requestors
  ,(
      select xia.request_id, 
        case when u.description in (
        'Guevarra, Alfred'
        ,'Meehan, Angela'
        ,'De Klerk, Anneli'
        ,'Thippeswamy, Arjun Bhari'
        ,'Massagli, Doug'
        ,'Nguyen, Doug'
        ,'Chun, Edward'
        ,'Evelyn, Iysha'
        ,'Bathla, Jashan'
        ,'Lim-Biz, Jeanne'
        ,'Reddy, Kartik'
        ,'Momotova, Kate'
        ,'Glenn, Kevin'
        ,'Shah, Koshambi'
        ,'Sodha, Kruti'
        ,'Brahmavar, Kush'
        ,'Costa, Leandro'
        ,'Day, Lorie'
        ,'Walker, Lynette'
        ,'Hansen, Marc'
        ,'Kavanagh, Mark'
        ,'Newton-Gruswitz, Mary King'
        ,'Chin, Melissa'
        ,'Musko, Melissa'
        ,'Crowley, Michael'
        ,'Zona, Mike'
        ,'Das, Mrinal'
        ,'Birch, Patrick'
        ,'Halder, Prasiddha'
        ,'Torres, Rafaela'
        ,'Abulbasal, Rana'
        ,'Knight, Rose'
        ,'Tanvir, Sadaaf'
        ,'Mathur, Santosh'
        ,'Chang, Shannon'
        ,'Millis-Wight, Shelley'
        ,'Ajwani, Tanmay'
        ,'Cramer, Yvonne'
        )
        then 'Infra' else 'Non-infra' end requestor_infra_flag
      from xxfb.xxfb_ap_isupplier_register xia, apps.fnd_user u
      where xia.created_by=u.user_id
  ) infra_requestors
where xia.request_id=step1.request_id(+)
and xia.request_id=step2.request_id(+)
and xia.request_id=step3.request_id(+)
and xia.request_id=step4.request_id(+)
and xia.request_id=step5.request_id(+)
and xia.request_id=step6.request_id(+)
and xia.request_id=step7.request_id(+)
and xia.request_id=step8.request_id(+)
and xia.request_id=step9.request_id(+)
and xia.request_id=step10.request_id(+)
and xia.request_id=step11.request_id(+)
and xia.request_id=stepX.request_id(+)
and xia.request_id=infra_po.request_id(+)
and xia.request_id= infra_requestors.request_id(+)
and xia.request_id = xas.request_id(+)
AND xia.fb_ou_id = hou.organization_id(+)
AND xia.supplier_reg_id = psr.supplier_reg_id(+)
and xia.request_id>1  -- 1 is for testing
and xia.created_by=u.user_id
)