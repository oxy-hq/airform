with  __dbt__cte__int_sap__purchasing_document_header as (


select
    mandt as client_id,
    ebeln as purchasing_document_id,
    bukrs as company_code_id,
    bstyp as purchasing_document_category,
    bsart as purchasing_document_type_id,
    bsakz as control_indicator,
    loekz as deletion_indicator,
    statu as status_purchasing_document,
    
    to_date(cast(aedat as TEXT), 'YYYYMMDD')
 as created_date,
    ernam as created_by,
    pincr as item_number_interval,
    lponr as last_item_number_id,
    lifnr as vendor_id,
    spras as language_key_id,
    zterm as payment_terms,
    zbd1t as payment_in,
    zbd2t as zbd2t,
    zbd3t as zbd3t,
    zbd1p as cash_discount_percentage_1,
    zbd2p as cash_discount_percentage_2,
    ekorg as purchasing_organization_id,
    ekgrp as purchasing_group_id,
    waers as currency_id,
    wkurs as exchange_rate,
    kufix as exchange_rate_fixed,
    
    to_date(cast(bedat as TEXT), 'YYYYMMDD')
 as purchasing_document_date,
    
    to_date(cast(kdatb as TEXT), 'YYYYMMDD')
 as start_validity_period_date,
    
    to_date(cast(kdate as TEXT), 'YYYYMMDD')
 as end_validity_period_date,
    
    to_date(cast(bwbdt as TEXT), 'YYYYMMDD')
 as closing_applications_date,
    
    to_date(cast(angdt as TEXT), 'YYYYMMDD')
 as quotation_deadline_date,
    
    to_date(cast(bnddt as TEXT), 'YYYYMMDD')
 as binding_period_quotation_date,
    
    to_date(cast(gwldt as TEXT), 'YYYYMMDD')
 as warranty_date,
    ausnr as bid_invitation_number_id,
    angnr as quotation_number,
    
    to_date(cast(ihran as TEXT), 'YYYYMMDD')
 as quotation_submission_date,
    ihrez as your_reference,
    verkf as salesperson,
    telf1 as vendors_telephone_number,
    llief as supplying_vendor_id,
    kunnr as customer_id,
    konnr as outline_agreement_id,
    abgru as field_not_used,
    autlf as complete_delivery,
    weakt as indicator_goods_receipt_message,
    reswk as supplying_plant_id,
    lblif as field_not_used_id,
    inco1 as incoterms_id,
    inco2 as incoterms_part_2,
    ktwrt as target_header_val,
    submi as collective_number,
    knumv as document_condition_no,
    kalsm as procedure_id,
    stafo as update_group_stats_id,
    lifre as different_invoicing_party_id,
    exnum as number_foreign_trade_id,
    unsez as our_reference,
    logsy as logical_system_id,
    upinc as subitem_interval,
    stako as time_dep_conditions,
    frggr as release_group_id,
    frgsx as release_strategy_id,
    frgke as release_indicator_id,
    frgzu as release_state,
    frgrl as subject_to_release,
    lands as country_tax_return_id,
    lphis as rel_documentation,
    adrnr as address_number_id,
    stceg_l as country_sales_tax_id_number_id,
    stceg as vat_registration_no,
    absgr as reason_cancellation_id,
    addnr as document_number_additional,
    kornr as corr_misc_provis,
    memory as purchase_order_not_yet_complete,
    procstat as purch_doc_proc_state,
    rlwrt as total_at_time_release_val,
    revno as version_number_in_purchasing,
    scmproc as scmproc,
    reason_code as goods_receipt_reason_code,
    memorytype as category_incompleteness,
    rettp as retention_indicator,
    retpc as retention_in_percent,
    dptyp as down_payment_indicator,
    dppct as down_payment_percentage,
    dpamt as down_payment_amount_val,
    
    to_date(cast(dpdat as TEXT), 'YYYYMMDD')
 as due_down_payment_date,
    msr_id as process_identification_number,
    hierarchy_exists as part_contract_hierarchy,
    threshold_exists as threshold_value_exchange_rates,
    legal_contract as legal_contract_number,
    description as contract_name,
    
    to_date(cast(release_date as TEXT), 'YYYYMMDD')
 as release_contract_date,
    vsart as shipping_type_id,
    handoverloc as handover_location,
    shipcond as shipping_conditions_id,
    incov as incoterms_version_id,
    inco2_l as incoterms_location_1,
    inco3_l as incoterms_location_2,
    force_id as internal_key_force_element,
    force_cnt as internal_version_counter,
    reloc_id as relocation_id,
    reloc_seq_id as relocation_step_id,
    source_logsys as source_logsys,
    fsh_transaction as transaction_number,
    fsh_item_group as item_group,
    fsh_vas_last_item as last_vas_item_number,
    fsh_os_stg_change as os_strategy_specific_fields_change,
    vzskz as interest_calculation_indicator_id,
    fsh_snst_status as snapshot_status,
    pohf_type as document_category,
    
    to_date(cast(eq_eindt as TEXT), 'YYYYMMDD')
 as same_delivery_date,
    eq_werks as same_plant_id,
    fixpo as firm_deal_indicator,
    ekgrp_allow as take_account_purch_group,
    werks_allow as take_account_plants,
    contract_allow as take_account_contracts,
    pstyp_allow as take_account_item_categories,
    fixpo_allow as take_account_fixed_date_purchases,
    key_id_allow as consider_budget,
    aurel_allow as take_account_alloc_table_relevance,
    delper_allow as take_account_dlvy_period,
    eindt_allow as take_account_delivery_date,
    ltsnr_allow as include_vendor_subrange,
    otb_level as otb_check_level,
    otb_cond_type as otb_condition_type_id,
    key_id as unique_number_budget,
    otb_value as required_budget_val,
    otb_curr as otb_currency_id,
    otb_res_value as reserved_budget_val,
    otb_spec_value as special_release_budget_val,
    spr_rsn_profile as otb_reason_profile_special_release,
    budg_type as budget_type,
    otb_status as otb_check_status,
    otb_reason as reason,
    check_type as type_otb_check,
    con_otb_req as otb_relevant_contract,
    con_prebook_lev as indicator_level_contracts,
    con_distr_lev as distrib_using_target_value_or_item,
    hvr_is_deleted as hvr_is_deleted,
    hvr_change_time as hvr_change_time
from "sap"."main_sap"."stg_sap__ekko"
),  __dbt__cte__int_sap__purchasing_document_category as (


with dd07l as (
    select *
    from "sap"."main_sap"."stg_sap__dd07l"



), dd07t as (
    select *
    from "sap"."main_sap"."stg_sap__dd07t"


), final as (
    select 
        dd07l.domvalue_l as purchasing_document_category_id,
        dd07l.hvr_change_time as hvr_change_time,
        dd07t.ddtext as purchasing_document_category_txt
    from dd07l

    
    left join dd07t
        on dd07l.domname = dd07t.domname
        and dd07l.domvalue_l = dd07t.domvalue_l
        and dd07l.as4vers = dd07t.as4vers
        and dd07t.ddlanguage in ('e')
    

    where dd07l.domname = 'bstyp'
        and dd07l.as4vers = '0000'
)

select *
from final
),  __dbt__cte__int_sap__purchasing_document_type as (


with t161 as (
    select *
    from "sap"."main_sap"."stg_sap__t161"



), t161t as (
    select *
    from "sap"."main_sap"."stg_sap__t161t"


), final as (
    select
        t161.mandt as client_id,
        t161.bstyp as purch_doc_category_id,
        t161.bsart as purchasing_document_type_id,
        t161.bsakz as control_indicator,
        t161.pincr as item_number_interval,
        t161.numki as no_range_int_assgt,
        t161.numke as no_range_ext_assg,
        t161.brefn as field_selection_key_id,
        t161.refba as reference_document_type_id,
        t161.abvor as stdrd_rel_order_qty,
        t161.stafo as update_group_stats_id,
        t161.upinc as subitem_interval,
        t161.stako as time_dep_conditions,
        t161.pargr as partner_determination_procedure_id,
        t161.numka as number_range_ale,
        t161.hityp as vendor_hierarchy_cat_id,
        t161.lphis as rel_documentation,
        t161.gsfrg as overall_release_requisitions,
        t161.variante as layout,
        t161.shenq as shared_lock_only,
        t161.kzale as distributed_contract_ale,
        t161.abgebot as global_perc_bid,
        t161.kornr as corr_misc_provis,
        t161.umlif as vendor,
        t161.koett as contract_with_delivery_schedule,
        t161.ar_object as document_type_id,
        t161.koako as koako,
        t161.oicsegi as qty_sched_permitted,
        t161.oirfqreq as precedence_f_rfq_req,
        t161.wvvkz as further_processing_summar_docs,
        t161.xlokz as cross_system_transit,
        t161.cp_aktive as commitment_plan_is_active,
        t161.cptype as category_commitment_plan,
        t161.fls_rsto as enh_store_return,
        t161.msr_active as adv_returns_active,
        t161.rdp_profile as risk_distribution_plan_profile_id,
        t161.numkc as srm_contract_number_range,
        t161._sapmp_ceact as sapmp_fastentry_chars_is_active,
        t161._sapmp_pdact as sapmp_activate_inheritance,
        t161._sapmp_pprot as sapmp_inheritance_log,
        t161._sapmp_puser as sapmp_inheritance_overwrite_user_values,
        t161._sapmp_pausw as sapmp_inheritance_char_selection_list,
        t161._sapmp_atnam as sapmp_characteristic_name,
        t161._sapmp_gauf as sapmp_global_local_group_may_be_undone,
        t161.tolsl as tolerance_key_id,
        t161.fsh_vas_act as vas_active_flag,
        t161.fsh_vas_kalsm as determination_procedure,
        t161.fsh_vas_del as vas_deletion_criteria,
        t161.fsh_vas_detdt as date_vas_determination,
        t161.fsh_excl_return as exclude_return_items,
        t161.fsh_var_kalsm as determination_procedure_id,
        t161.fsh_dpr_detpro as fsh_dpr_detpro,
        t161.fsh_po_idoc as generic_article_in_po_using_idoc,
        t161.mill_omkz as use_ref_characteristics,
        t161.wrf_enable_dateline as enable_dateline,
        t161.hvr_is_deleted as hvr_is_deleted,
        t161.hvr_change_time as hvr_change_time,
        t161t.batxt as doc_type_descript
    from t161

    
    left join t161t
        on t161.mandt = t161t.mandt
        and t161.bsart = t161t.bsart
        and t161.bstyp = t161t.bstyp
        and t161t.spras = 'e'
    
)

select *
from final
),  __dbt__cte__int_sap__purchasing_group as (


select
    ekgrp as purchasing_group_id,
    mandt as client_id,
    tel_number as telephone,
    telfx as fax_number,
    ldest as spool_output_device_id,
    ektel as tel_no_purch_group,
    smtp_addr as e_mail_address,
    tel_extens as telephone_no_extension,
    eknam as description_purchasing_group,
    _fivetran_deleted as _fivetran_deleted,
    _fivetran_synced as _fivetran_synced,
    _fivetran_sap_archived as _fivetran_sap_archived
from "sap"."main_sap"."stg_sap__t024"
),  __dbt__cte__int_sap__purchasing_document_status as (


with dd07l as (
    select *
    from "sap"."main_sap"."stg_sap__dd07l"



), dd07t as (
    select *
    from "sap"."main_sap"."stg_sap__dd07t"


), final as (
    select 
        dd07l.domvalue_l as document_status_id,
        dd07l.hvr_change_time as hvr_change_time,
        dd07t.ddtext as document_status_txt
    from dd07l

    
    left join dd07t
        on dd07l.domname = dd07t.domname
        and dd07l.domvalue_l = dd07t.domvalue_l
        and dd07l.as4vers = dd07t.as4vers
        and dd07t.ddlanguage in ('e')
    

    where dd07l.domname = 'statv'
        and dd07l.as4vers = '0000'
)

select *
from final
), purchasing_document_header as (
    select *
    from __dbt__cte__int_sap__purchasing_document_header
)


, purchasing_document_category as (
    select *
    from __dbt__cte__int_sap__purchasing_document_category
)



, purchasing_document_type as (
    select *
    from __dbt__cte__int_sap__purchasing_document_type
)



, purchasing_group as (
    select *
    from __dbt__cte__int_sap__purchasing_group
)



, purchasing_document_status as (
    select *
    from __dbt__cte__int_sap__purchasing_document_status
)


, final as (
    select
        purchasing_document_header.purchasing_document_id,
        purchasing_document_header.purchasing_document_category,
        purchasing_document_header.purchasing_document_type_id,
        purchasing_document_header.purchasing_group_id,
        purchasing_document_header.status_purchasing_document as purchasing_document_status,
        purchasing_document_header.payment_terms,
        purchasing_document_header.reason_cancellation_id,
        purchasing_document_header.company_code_id

        
        , purchasing_document_category.purchasing_document_category_txt
        

        
        , purchasing_document_type.doc_type_descript as purchasing_document_type_text
        

        
        , purchasing_group.description_purchasing_group
        

        
        , purchasing_document_status.document_status_txt as purchasing_document_status_txt
        

    from purchasing_document_header

    
    left join purchasing_document_category
        on purchasing_document_header.purchasing_document_category = purchasing_document_category.purchasing_document_category_id  
    

    
    left join purchasing_document_type
        on purchasing_document_header.purchasing_document_type_id = purchasing_document_type.purchasing_document_type_id 
        and purchasing_document_type.purch_doc_category_id = purchasing_document_header.purchasing_document_category 
    

    
    left join purchasing_group
        on purchasing_group.purchasing_group_id = purchasing_document_header.purchasing_group_id 
    

    
    left join purchasing_document_status
        on purchasing_document_status.document_status_id = purchasing_document_header.status_purchasing_document
    
)

select *
from final
