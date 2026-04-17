with  __dbt__cte__int_sap__purchasing_document_item as (


select
    mandt as client_id,
    ebeln as purchasing_document_id,
    ebelp as purchasing_document_item_id,
    loekz as deletion_indicator,
    statu as rfq_status,
    
    to_date(cast(aedat as TEXT), 'YYYYMMDD')
 as last_changed_on_date,
    txz01 as short_text,
    matnr as material_id,
    ematn as material_number_id,
    bukrs as company_code_id,
    werks as plant_id,
    lgort as storage_location_id,
    bednr as requirement_tracking_number,
    matkl as material_group_id,
    infnr as number_purchasing_info_id,
    idnlf as material_number_used_by_vendor,
    ktmng as target_quantity,
    menge as purchase_order_quantity,
    meins as order_uom_id,
    bprme as order_price_purchasing_uom_id,
    bpumz as quantity_conversion,
    bpumn as bpumn,
    umrez as equal_to,
    umren as denominator,
    netpr as net_order_price_val,
    peinh as price_unit,
    netwr as net_order_po_currency_val,
    brtwr as gross_order_po_currency_val,
    
    to_date(cast(agdat as TEXT), 'YYYYMMDD')
 as quotation_deadline_date,
    webaz as gr_processing_time,
    mwskz as tax_code_id,
    bonus as settlement_group_1_purchasing,
    insmk as stock_type,
    spinf as indicator_update_info,
    prsdr as price_printout,
    schpr as indicator_estimated_price,
    mahnz as number_reminders_expediters,
    mahn1 as _1st_reminder_exped,
    mahn2 as _2nd_reminder_exped,
    mahn3 as _3rd_reminder_exped,
    uebto as overdelivery_tolerance_limit,
    uebtk as unltd_overdelivery,
    untto as underdelivery_tolerance_limit,
    bwtar as valuation_type_id,
    bwtty as valuation_category_id,
    abskz as rejection_indicator,
    agmem as internal_comment_on_quotation_id,
    elikz as delivery_completed,
    erekz as final_invoice_indicator,
    pstyp as item_category_id,
    knttp as account_assignment_category_id,
    kzvbr as consumption_posting,
    vrtkz as distribut_indicator,
    twrkz as partial_invoice_indicator,
    wepos as goods_receipt_indicator,
    weunb as goods_receipt_non_valuated,
    repos as invoice_receipt_indicator,
    webre as gr_based_inv_verif,
    kzabs as order_acknowledgment_requirement,
    labnr as order_acknowledgment_number,
    konnr as outline_agreement_id,
    ktpnr as princ_agreement_item_id,
    
    to_date(cast(abdat as TEXT), 'YYYYMMDD')
 as reconciliation_date,
    abftz as agreed_cumulative_quantity,
    etfz1 as firm_zone,
    etfz2 as trade_off_zone,
    kzstu as binding_on_mrp,
    notkz as exclusion_indicator,
    lmein as base_uom_id,
    evers as shipping_instruction_id,
    zwert as oa_target_val,
    navnw as non_deductible_put_tax_val,
    abmng as standard_release_order_quantity,
    
    to_date(cast(prdat as TEXT), 'YYYYMMDD')
 as price_determination_date,
    bstyp as purch_doc_category,
    effwr as effective_item_val,
    xoblr as item_affects_commitments,
    kunnr as customer_id,
    adrnr as address_id,
    ekkol as condition_group_with_vendor,
    sktof as no_cash_discount,
    stafo as update_group_stats_id,
    plifz as planned_delivery_time_in_days,
    ntgew as net_weight,
    gewei as weight_uom_id,
    txjcd as tax_jurisdiction_id,
    etdrk as print_relevant,
    sobkz as special_stock_id,
    arsnr as settlement_reservation_number,
    arsps as item_settlem_reser,
    insnc as not_changeable,
    ssqss as qm_control_key_id,
    zgtyp as certificate_type_id,
    ean11 as ean,
    bstae as confirmation_control_key_id,
    revlv as revision_level,
    geber as fund_id,
    fistl as funds_center_id,
    fipos as commitment_item_id,
    ko_gsber as bus_area_reported_to_partner_id,
    ko_pargb as partners_assumed_bus_area_id,
    ko_prctr as profit_center_id,
    ko_pprctr as partner_profit_center_id,
    meprf as pricing_date_control,
    brgew as gross_weight,
    volum as volume,
    voleh as volume_uom_id,
    inco1 as incoterms_id,
    inco2 as incoterms_part_2,
    vorab as advance_procurement,
    kolif as prior_vendor_id,
    ltsnr as vendor_subrange_id,
    packno as package_number_id,
    fplnr as invoicing_plan_number,
    gnetwr as currently_not_used_val,
    stapo as item_is_statistical,
    uebpo as higher_level_item_id,
    
    to_date(cast(lewed as TEXT), 'YYYYMMDD')
 as latest_possible_goods_receipt_date,
    emlif as vendor_id,
    lblkz as subcontracting_vendor,
    satnr as cross_plant_cm_id,
    attyp as material_category,
    vsart as shipping_type_id,
    handoverloc as handover_location,
    kanba as kanban_indicator,
    adrn2 as number_delivery_address_id,
    cuobj as internal_object_no,
    xersy as eval_receipt_sett,
    
    to_date(cast(eildt as TEXT), 'YYYYMMDD')
 as gr_b_settlement_from_date,
    
    to_date(cast(drdat as TEXT), 'YYYYMMDD')
 as last_transmission_date,
    druhr as tim,
    drunr as sequential_number,
    aktnr as promotion_id,
    abeln as allocation_table_number_id,
    abelp as item_number_allocation_table_id,
    anzpu as number_points,
    punei as points_uom_id,
    saiso as season_category_id,
    saisj as season_year,
    ebon2 as settlement_group_2,
    ebon3 as settlement_group_3,
    ebonf as subseq_settlement,
    mlmaa as mat_ledger_active,
    mhdrz as minimum_remaining_shelf_life,
    anfnr as rfq_number_id,
    anfps as item_number_rfq_id,
    kzkfg as origin_configuration,
    usequ as quota_arrangement_usage_id,
    umsok as sp_ind_stock_tfr_id,
    banfn as purchase_requisition_number,
    bnfpo as item_requisition_id,
    mtart as material_type_id,
    uptyp as subitem_category_id,
    upvor as subitems_exist,
    kzwi1 as subtotal_1_val,
    kzwi2 as subtotal_2_val,
    kzwi3 as subtotal_3_val,
    kzwi4 as subtotal_4_val,
    kzwi5 as subtotal_5_val,
    kzwi6 as subtotal_6_val,
    sikgr as processing_key_sub_items_id,
    mfzhi as maximum_cmg_quantity,
    ffzhi as maximum_cum_pgq,
    retpo as returns_item,
    aurel as relevant_to_allocation_table,
    bsgru as reason_ordering_id,
    lfret as del_type_f_returns_id,
    mfrgr as material_freight_group_id,
    nrfhg as qual_f_freegoodsdis,
    j_1bnbm as brazilian_ncm_code_id,
    j_1bmatuse as usage_the_material,
    j_1bmatorg as origin_the_material,
    j_1bownpro as produced_in_house,
    j_1bindust as material_cfop_category,
    abueb as release_creation_profile_id,
    
    to_date(cast(nlabd as TEXT), 'YYYYMMDD')
 as next_forecast_delivery_schedule_transm_date,
    
    to_date(cast(nfabd as TEXT), 'YYYYMMDD')
 as next_jit_delivery_schedule_transmission_date,
    kzbws as special_stock_valuation,
    bonba as rebate_basis_1_val,
    fabkz as jit_sched_indicator,
    j_1aindxp as inflation_index_id,
    
    to_date(cast(j_1aidatep as TEXT), 'YYYYMMDD')
 as inflation_index_date,
    mprof as mfr_part_profile_id,
    eglkz as final_delivery,
    kztlf as partial_deliv_item,
    kzfme as units_measure_usage,
    rdprf as rounding_profile_id,
    techs as standard_variant,
    chg_srv as configuration_changed,
    chg_fplnr as chg_fplnr,
    mfrpn as manufacturer_part_number,
    mfrnr as manufacturer_number_id,
    emnfr as ext_manufacturer,
    novet as item_blocked_sd_delivery,
    afnam as name_requisitioner_requester,
    tzonrc as time_zone_recipient_location_id,
    iprkz as period_ind_sled,
    lebre as service_based_invoice_verification,
    berid as mrp_area_id,
    xconditions as xconditions,
    apoms as apo_as_planning_system,
    ccomp as stock_transfer_cat,
    grant_nbr as _grant,
    fkber as functional_area_id,
    status as item_status,
    reslo as issuing_storage_loc_id,
    kblnr as earmarked_funds_id,
    kblpos as earmarked_funds_document_item_id,
    weora as acceptance_at_origin,
    srv_bas_com as service_based_commitment,
    prio_urg as requirement_urgency_id,
    prio_req as requirement_priority_id,
    empst as receiving_point,
    diff_invoice as differential_invoicing,
    trmrisk_relevant as risk_relevancy_in_purchasing,
    spe_abgru as reason_rejection,
    spe_crm_so as crm_sales_order_number_tpop_process,
    spe_crm_so_item as crm_sales_order_item_number_in_tpop_proc,
    spe_crm_ref_so as crm_ref_order_number_tpop_process,
    spe_crm_ref_item as crm_reference_item_number_in_tpop_proc,
    spe_crm_fkrel as billing_relevance_crm,
    spe_chng_sys as last_changers_system_type,
    spe_insmk_src as source_stor_loc_stock_type,
    spe_cq_ctrltype as cq_control_type,
    spe_cq_nocq as no_transmission_cqs_in_sa_release,
    reason_code as goods_receipt_reason_code,
    cqu_sar as cumulative_grs_from_redirected_pos,
    anzsn as number_serial_numbers,
    spe_ewm_dtc as ewm_del_tol_chk,
    exlin as item_number_length,
    exsnr as external_sorting,
    ehtyp as external_hierarchy_category_id,
    retpc as retention_in_percent,
    dptyp as down_payment_indicator,
    dppct as down_payment_percentage,
    dpamt as down_payment_amount_val,
    
    to_date(cast(dpdat as TEXT), 'YYYYMMDD')
 as due_down_payment_date,
    fls_rsto as enh_store_return,
    ext_rfx_number as document_no_external_doc,
    ext_rfx_item as item_number_external_document,
    ext_rfx_system as logical_system_id,
    srm_contract_id as central_contract,
    srm_contract_itm as central_contract_item_number,
    blk_reason_id as blocking_reason_id,
    blk_reason_txt as blocking_reason_text,
    itcons as real_time_cons_post,
    fixmg as delivery_date_and_quantity_fixed,
    wabwe as gi_based_goods_rcpt,
    cmpl_dlv_itm as complete_delivery,
    inco2_l as incoterms_location_1,
    inco3_l as incoterms_location_2,
    tc_aut_det as tax_code_automatically_determined_id,
    manual_tc_reason as manual_tax_code_reason_id,
    fiscal_incentive as tax_incentive_type_id,
    tax_subject_st as tax_subject_to_substituicao_tributaria,
    fiscal_incentive_id as incentive_id,
    sf_txjcd as origin_jurisd_code_id,
    _bev1_negen_item as bev1_indicator_item_is_generated,
    _bev1_nedepfree as bev1_dependent_items_free,
    _bev1_nestruccat as bev1_structure_category,
    advcode as advice_code_id,
    budget_pd as budget_period_id,
    excpe as acceptance_period,
    fmfgus_key as us_government_fields,
    iuid_relevant as iuid_relevant,
    mrpind as max_retail_price_relevant,
    oipipeval as val_ind_pipeline,
    oic_lifnr as oic_lifnr,
    oic_dcityc as destination_city_code_id,
    oic_dcounc as destination_county_code_id,
    oic_dregio as destination_region_id,
    oic_dland1 as destination_country_id,
    oic_ocityc as origin_city_code_id,
    oic_ocounc as origin_county_code_id,
    oic_oregio as origin_region_id,
    oic_oland1 as origin_country_id,
    oic_porgin as tax_origin,
    oic_pdestn as tax_destination,
    oic_ptrip as pipeline_trip_number_external,
    oic_pbatch as pipe_ex_batch_no,
    oic_mot as mode_transport_id,
    oic_aorgin as alternate_origin,
    oic_adestn as alternate_destination,
    oic_truckn as truck_number,
    oia_baselo as base_location,
    oitaxfrom as tax_key_from_id,
    oihantyp as handling_type_id,
    oipricie as ed_pricing_external,
    oitaxto as tax_key_to_id,
    oitaxcon as excise_duty_tax_val,
    oitaxgrp as excise_duty_group_id,
    oioilcon as oil_content_perc,
    oiinex as ed_pricing_key_id,
    oiexgnum as exchange_agreement_number_id,
    oiexgtyp as exchange_type_id,
    oifeetot as fee_total_val,
    
    to_date(cast(oifeedt as TEXT), 'YYYYMMDD')
 as fee_pricing_condition_date,
    oinetcyc as netting_cycle_id,
    oiferp as fee_repricing_indicator,
    oifeech as fee_edit_control,
    oia_ipmvat as vat_on_int_mat,
    oia_spltiv as split_invoice_verif,
    oivath as loccur_amount,
    oivatf as amount_document_currency_val,
    oisbrel as s_b_prod_relev_ind,
    oibasprod as base_product_number_id,
    oitrknr as tracking_number,
    oitrkjr as tracking_number_year,
    oiextnr as external_tracking_number,
    oiitmnr as tracking_number_item_line,
    oiftind as final_transfer_indicator,
    oipriop as price_opt_gains,
    oitrind as transfer_sign,
    oighndl as gain_handling,
    oiumbar as val_type_issuing_loc_id,
    oitxcon1 as ed_tax_1_val,
    oitxcon2 as ed_tax_2_val,
    oitxcon3 as ed_tax_3_val,
    oitxcon4 as ed_tax_4_val,
    oitxcon5 as ed_tax_5_val,
    oitxcon6 as ed_tax_6_val,
    oid_extbol as external_bill_lading,
    oid_miscdl as miscellaneous_delivery_number,
    oimatcyc as material_inv_cycle_id,
    oiedok as excise_duty_validation_indicator,
    oiedbal as ed_balance_indicator,
    oiedbalm as balance_method_ind,
    oicertf1 as external_license_no,
    
    to_date(cast(oidatfm1 as TEXT), 'YYYYMMDD')
 as valid_from_date,
    
    to_date(cast(oidatto1 as TEXT), 'YYYYMMDD')
 as valid_to_date,
    oih_lictp as license_type_id,
    oih_licin as internal_license_no_id,
    oih_lcfol as follow_on_license_id,
    oih_folqty as _2nd_license_qty,
    oiedok_gi as ed_validation,
    oiedbal_gi as excise_duty_balance,
    oiedbalm_gi as balance_method,
    oihantyp_gi as oihantyp_gi,
    oiinex_gi as oiinex_gi,
    oitaxgrp_gi as oitaxgrp_gi,
    oicertf1_gi as ext_license_no_gi,
    
    to_date(cast(oidatfm1_gi as TEXT), 'YYYYMMDD')
 as oidatfm1_gi,
    
    to_date(cast(oidatto1_gi as TEXT), 'YYYYMMDD')
 as oidatto1_gi,
    oih_lictp_gi as license_type_to_material_sto_id,
    oih_licin_gi as inter_license_no_to_id,
    oih_lcfol_gi as oih_lcfol_gi,
    oih_folqty_gi as oih_folqty_gi,
    sgt_scat as stock_segment,
    sgt_rcat as requirement_segment,
    wrf_charstc1 as characteristic_value_1,
    wrf_charstc2 as characteristic_value_2,
    wrf_charstc3 as characteristic_value_3,
    refsite as reference_site_purchasing,
    _accgo_is_co_rel as accgo_call_off_applies,
    serru as type_subcontracting,
    sernp as serial_number_profile_id,
    disub_sobkz as special_stock,
    disub_pspnr as wbs_element_id,
    disub_kunnr as disub_kunnr,
    disub_vbeln as sales_document_id,
    disub_posnr as sd_item_id,
    disub_owner as owner_stock_id,
    fsh_season_year as fsh_season_year,
    fsh_season as season_id,
    fsh_collection as fashion_collection,
    fsh_theme as fashion_theme,
    
    to_date(cast(fsh_atp_date as TEXT), 'YYYYMMDD')
 as starting_with_atp_date,
    fsh_vas_rel as vas_relevant,
    fsh_vas_prnt_id as fsh_vas_prnt_id,
    fsh_transaction as transaction_number,
    fsh_item_group as item_group,
    fsh_item as item_number,
    fsh_ss as order_scheduling_strategy,
    fsh_grid_cond_rec as grid_condition_number,
    fsh_psm_pfm_split as psm_and_pfm_split_id,
    cnfm_qty as committed_quantity,
    ref_item as reference_item_id,
    source_id as origin_profile_id,
    source_key as key_in_source_system,
    put_back as put_back_indicator,
    pol_id as order_list_item_number,
    cons_order as purchase_order_consignment,
    hvr_is_deleted as hvr_is_deleted,
    hvr_change_time as hvr_change_time
from "sap"."main_sap"."stg_sap__ekpo"
),  __dbt__cte__int_sap__purchasing_document_header as (


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
),  __dbt__cte__int_sap__company as (


select
    bukrs as company_code_id,
    mandt as client_id,
    dkweg as import_gr,
    xgjrv as indicator_propose_fiscal_year,
    xeink as purchase_acct_proc,
    fdbuk as cash_management_company_code_id,
    pp_pdate as posting_date_parking,
    xprod as company_code_is_productive,
    xskfn as discount_base_is_net_value,
    xcovr as indicator_hedge_request_active,
    ebukr as original_key_the_company_code,
    bukrs_glob as name_global_company_code_id,
    xmwsn as tax_base_is_net_value,
    butxt as company_code_txt,
    bapovar as ba_variant_id,
    xbbko as contract,
    dttdsp as remittance_challan_document_type_id,
    dtaxr as deferred_tax_rule_id,
    impda as import_in_po,
    kkber as credit_control_area_id,
    xfmca as update_fm,
    xfmcb as csh_bdgt_mgt_active,
    surccm as surcharge_calculation_method,
    fstvare as field_status_variant_id,
    periv as fiscal_year_variant_id,
    txjcd as jurisdiction_code_id,
    fmhrdate as fds_ctr_active_in_hr_date,
    xbbba as purchase_requisition,
    ort01 as city,
    rcomp as company_id,
    xsplt as enable_amount_split,
    kopim as copying_control_gr,
    infmt as inflation_method_id,
    fm_derive_acc as activate_aa_derivation,
    ktopl as chart_of_accounts_id,
    umkrs as sales_purchases_tax_group_id,
    xkkbi as control_area_can_be_input,
    pst_per_var as manage_posting_period_cocode_ledger,
    xvatdate as tax_reporting_date_active,
    txkrs as cur_transl_tax,
    waers as currency_id,
    xkdft as post_translation,
    xcos as cost_sales_accounting_status,
    xbbbf as inventory_management,
    xbbsc as shopping_cart,
    xfmco as project_cash_mgmt_active,
    dttaxc as document_type_jv_tax_code_id,
    mregl as sample_acct_rules_var_id,
    mwskv as input_tax_code_id,
    xstdt as tax_determ_with_doc_date,
    xnegp as negative_postings_permitted,
    spras as language_key_id,
    xvvwa as financial_assets_mgmt_active,
    dtprov as document_type_provisions_taxes_id,
    waabw as max_exchange_rate_deviation,
    wt_newwt as extended_withholding_tax_active,
    xcession as accts_recble_pled_active,
    xslta as no_forex_rate_diff_when_clearing_in_lc,
    adrnr as address_id,
    xjvaa as indicator_jva_active,
    opvar as posting_period_variant_id,
    mwska as output_tax_code_id,
    kokfi as allocation_indicator,
    ktop2 as country_chart_accts_id,
    xextb as external_co_code,
    buvar as company_code_variant_screen,
    offsacct as method_offsttng_acct,
    dtamtc as document_type_jv_amount_correction_id,
    wfvar as workflow_variant_id,
    land1 as country_key_id,
    fstva as fstva,
    xfdis as cash_management_activated,
    xbbbe as po_scheduling_agmt,
    xvalv as define_default_value_date,
    fikrs as financial_management_area_id,
    xfdsd as update_sd_in_cmf,
    xfdmm as update_mm_in_cmf,
    xgsbe as business_area_fin_statements,
    stceg as vat_registration_no,
    _fivetran_deleted as _fivetran_deleted,
    _fivetran_synced as _fivetran_synced,
    _fivetran_sap_archived as _fivetran_sap_archived

from "sap"."main_sap"."stg_sap__t001"
),  __dbt__cte__int_sap__purchasing_document_history as (


select
    mandt as client_id,
    ebeln as purchasing_document_id,
    ebelp as purchasing_document_item_id,
    zekkn as seq_no_account_assgt_id,
    vgabe as trans_event_type_id,
    gjahr as material_document_year_id,
    belnr as material_document_id,
    buzei as item_in_material_document_id,
    bewtp as purchase_order_history_category_id,
    bwart as movement_type_id,
    
    to_date(cast(budat as TEXT), 'YYYYMMDD')
 as posting_in_the_document_date,
    menge as qty,
    bpmng as quantity_in_opun,
    dmbtr as loccur_amount,
    wrbtr as amount_document_currency_val,
    waers as currency_id,
    arewr as gr_ir_clearg_local_currency_val,
    wesbs as gr_blck_stock_in_oun,
    bpwes as gr_blocked_stck_opun,
    shkzg as debitcredit_indicator,
    bwtar as valuation_type_id,
    elikz as delivery_completed,
    xblnr as reference_document_number,
    lfgja as fisc_year_ref_doc,
    lfbnr as reference_document,
    lfpos as item_reference_document,
    grund as reason_movement_id,
    
    to_date(cast(cpudt as TEXT), 'YYYYMMDD')
 as entry_date,
    cputm as entry_tim,
    reewr as voice_val,
    evere as compliance_with_shipping_instr_id,
    refwr as voice_fc_val,
    matnr as material_id,
    werks as plant_id,
    xwsbr as revgr_despite_ir,
    etens as sequential_number,
    knumv as document_condition_no,
    mwskz as tax_code_id,
    lsmng as del_note_quantity,
    lsmeh as delivery_note_uom_id,
    ematn as material_number_id,
    areww as gr_ir_clearg_fc_val,
    hswae as local_currency_key_id,
    bamng as bamng,
    charg as batch_id,
    
    to_date(cast(bldat as TEXT), 'YYYYMMDD')
 as document_in_document_date,
    xwoff as calculation_val_open,
    xunpl as unplanned_acct_assgmt_inv_verification,
    ernam as created_by,
    srvpos as service_number_id,
    packno as package_number_service_id,
    introw as line_number_service,
    bekkn as number_po_account_assignment,
    lemin as returns_indicator,
    arewb as arewb,
    rewrb as voice_amount_po_currency_val,
    saprl as sap_release,
    menge_pop as menge_pop,
    bpmng_pop as bpmng_pop,
    dmbtr_pop as dmbtr_pop,
    wrbtr_pop as wrbtr_pop,
    wesbb as val_gr_blocked_stock_in_oun,
    bpweb as valuated_gr_blocked_stock_in_opun,
    weora as acceptance_at_origin,
    arewr_pop as arewr_pop,
    kudif as exchange_rate_difference_amount_val,
    retamt_fc as retention_document_currency_val,
    retamt_lc as retention_company_code_currency_val,
    retamtp_fc as posted_retention_document_currency_val,
    retamtp_lc as posted_security_retention_cc_crcy_val,
    xmacc as multiple_account_assignment,
    wkurs as exchange_rate,
    inv_item_origin as origin_an_invoice_item,
    vbeln_st as delivery_id,
    vbelp_st as delivery_item_id,
    sgt_scat as stock_segment,
    et_upd as slqupd,
    j_sc_die_comp_f as depreciation_completion_flag,
    fsh_season_year as season_year,
    fsh_season as season_id,
    fsh_collection as fashion_collection,
    fsh_theme as fashion_theme,
    wrf_charstc1 as characteristic_value_1,
    wrf_charstc2 as characteristic_value_2,
    wrf_charstc3 as characteristic_value_3,
    hvr_is_deleted as hvr_is_deleted,
    hvr_change_time as hvr_change_time
from "sap"."main_sap"."stg_sap__ekbe"
),  __dbt__cte__int_sap__purchasing_document_overview as (


select
    purchasing_document_id,
    purchasing_document_item_id,
    max(delivery_completed) delivery_completed,
    max(case when trans_event_type_id = '1' then posting_in_the_document_date else null end) as latest_goods_receive_date,
    max(case when trans_event_type_id = '2' then posting_in_the_document_date else null end) as latest_invoice_receive_date,
    sum(case when trans_event_type_id = '1' then case when debitcredit_indicator = 'h' then -1*qty else qty end else null end) as received_quantity,
    sum(case when trans_event_type_id = '1' then case when debitcredit_indicator = 'h' then -1*loccur_amount else loccur_amount end else null end) as received_value_in_local_curr,
    sum(case when trans_event_type_id = '1' then case when debitcredit_indicator = 'h' then -1*amount_document_currency_val else amount_document_currency_val end else null end) as received_value_in_doc_curr,
    sum(case when trans_event_type_id = '2' then case when debitcredit_indicator = 'h' then -1*qty else qty end else null end) as invoice_quantity, 
    sum(case when trans_event_type_id = '2' then case when debitcredit_indicator = 'h' then -1*voice_val else voice_val end else null end) as invoice_value_local_curr,
    sum(case when trans_event_type_id = '2' then case when debitcredit_indicator = 'h' then -1*voice_fc_val else voice_fc_val end else null end) as invoice_value_foreign_curr,
    max(hvr_change_time) hvr_change_time,
    max(hvr_is_deleted) hvr_is_deleted 
from __dbt__cte__int_sap__purchasing_document_history
group by 1,2
),  __dbt__cte__int_sap__purchasing_document_schedule_line as (


select
    mandt as client_id,
    ebeln as purchasing_document_id,
    ebelp as purchasing_document_item_id,
    etenr as delivery_schedule_line_counter_id,
    
    to_date(cast(eindt as TEXT), 'YYYYMMDD')
 as item_delivery_date,
    
    to_date(cast(slfdt as TEXT), 'YYYYMMDD')
 as stat_rel_del_date,
    lpein as category_delivery_date_id,
    menge as scheduled_quantity,
    ameng as previous_quantity,
    wemng as quantity_goods_received,
    wamng as issued_quantity,
    uzeit as delivery_date_spot_tim,
    banfn as purchase_requisition_number,
    bnfpo as item_requisition_id,
    estkz as creation_indicator,
    qunum as number_quota_arrangement,
    qupos as quota_arrangement_item,
    mahnz as no_rem_expediters,
    
    to_date(cast(bedat as TEXT), 'YYYYMMDD')
 as order_schedule_line_date,
    rsnum as reservation_id,
    sernr as bom_explosion_number_id,
    fixkz as schedule_line_is_fixed,
    glmng as qty_delivered,
    dabmg as quantity_reduced_mrp,
    charg as batch_id,
    licha as vendor_batch_number,
    chkom as components,
    verid as production_version_id,
    abart as release_type,
    mng02 as committed_quantity,
    
    to_date(cast(dat01 as TEXT), 'YYYYMMDD')
 as committed_date,
    
    to_date(cast(altdt as TEXT), 'YYYYMMDD')
 as previous_delivery_date,
    aulwe as route_schedule_id,
    
    to_date(cast(mbdat as TEXT), 'YYYYMMDD')
 as material_availability_date,
    mbuhr as matl_staging_tim,
    
    to_date(cast(lddat as TEXT), 'YYYYMMDD')
 as loading_date,
    lduhr as loading_tim,
    
    to_date(cast(tddat as TEXT), 'YYYYMMDD')
 as transportation_planning_date,
    tduhr as transp_plan_tim,
    
    to_date(cast(wadat as TEXT), 'YYYYMMDD')
 as goods_issue_date,
    wauhr as goods_issue_tim,
    
    to_date(cast(eldat as TEXT), 'YYYYMMDD')
 as goods_receipt_end_date,
    eluhr as goods_receipt_end_tim,
    anzsn as number_serial_numbers,
    nodisp as reservation_purc_req,
    geo_route as geographical_route,
    route_gts as gts_route_code,
    gts_ind as goods_traffic_type,
    tsp as forwarding_agent_id,
    cd_locno as location_number_in_apo,
    cd_loctype as apo_location_type,
    
    to_date(cast(handoverdate as TEXT), 'YYYYMMDD')
 as handover_date,
    handovertime as handover_tim,
    fsh_ralloc_qty as requirement_allocated_quantity,
    fsh_salloc_qty as allocated_stock_quantity,
    fsh_os_id as order_scheduling_group_id,
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
    dl_id as dateline_id_guid,
    
    to_date(cast(handover_date as TEXT), 'YYYYMMDD')
 as transfer_date,
    no_scem as no_scem_controlling,
    
    to_date(cast(dng_date as TEXT), 'YYYYMMDD')
 as rem_date,
    dng_time as reminder_tim,
    cncl_ancmnt_done as cancellation_threat_made,
    dateshift_number as number_current_date_shifts,
    hvr_is_deleted as hvr_is_deleted,
    hvr_change_time as hvr_change_time
from "sap"."main_sap"."stg_sap__eket"
),  __dbt__cte__int_sap__purchasing_document_schedule_total as (


select
    purchasing_document_id, 
    purchasing_document_item_id, 
    max(item_delivery_date) as lastest_scheduled_delivery_date,
    sum(scheduled_quantity) as total_scheduled_delivery_quantity
from __dbt__cte__int_sap__purchasing_document_schedule_line
group by 1,2
), purchasing_document_item as (
    select *
    from __dbt__cte__int_sap__purchasing_document_item


), purchasing_document_header as (
    select *
    from __dbt__cte__int_sap__purchasing_document_header



), company as (
    select *
    from __dbt__cte__int_sap__company



), purchasing_document_overview as (
    select *
    from __dbt__cte__int_sap__purchasing_document_overview



), purchasing_document_schedule_total as (
    select *
    from __dbt__cte__int_sap__purchasing_document_schedule_total


), final as (
    select
        purchasing_document_item.purchasing_document_id,
        purchasing_document_item.purchasing_document_item_id,
        purchasing_document_item.material_id,
        purchasing_document_item.plant_id,
        purchasing_document_item.order_uom_id,
        purchasing_document_item.returns_item,
        purchasing_document_item.rejection_indicator,
        purchasing_document_item.net_order_po_currency_val as purchasing_document_currency_amount,
        case 
            when purchasing_document_item.returns_item = ''
                then purchasing_document_item.purchase_order_quantity
            else -1 * purchasing_document_item.purchase_order_quantity
        end as purchase_order_quantity,
        case
            when lower(purchasing_document_item.rejection_indicator) = 'x'
                then purchasing_document_item.purchase_order_quantity
            else cast(0 as numeric(28,6))
        end as cancel_purchase_quantity

        
        , purchasing_document_header.company_code_id
        , purchasing_document_header.purchasing_group_id
        , purchasing_document_header.purchasing_organization_id
        , purchasing_document_header.vendor_id
        , purchasing_document_header.purchasing_document_date
        , purchasing_document_header.exchange_rate
        , purchasing_document_header.currency_id as document_currency_id
        , cast(
            purchasing_document_item.net_order_po_currency_val *
            case
                when purchasing_document_header.exchange_rate < 0
                    then -1 / purchasing_document_header.exchange_rate
                else purchasing_document_header.exchange_rate
            end as numeric(28,6)
        ) as purchase_order_amount
        , case
            when lower(purchasing_document_item.rejection_indicator) = 'x'
                then cast(purchasing_document_item.net_order_po_currency_val * case
                    when purchasing_document_header.exchange_rate < 0
                        then - 1 / purchasing_document_header.exchange_rate
                    else purchasing_document_header.exchange_rate
                    end as numeric(28,6)
                    )
            else cast(0 as numeric(28,6))
		end as cancel_purchase_amount
        

        
        , company.currency_id
        

        
        , purchasing_document_schedule_total.lastest_scheduled_delivery_date as scheduled_delivery_date
        

        
        , purchasing_document_overview.latest_goods_receive_date
        , purchasing_document_overview.received_quantity as purchasing_delivered_quantity
        , purchasing_document_overview.received_value_in_local_curr as purchase_delivered_amount
        , purchasing_document_overview.invoice_value_local_curr as purchase_invoiced_amount
        , purchasing_document_overview.delivery_completed
        , case
            when purchasing_document_item.delivery_completed <> ''
                then cast(0 as numeric(28,6))
            else (purchasing_document_item.purchase_order_quantity - coalesce(purchasing_document_overview.received_quantity, 0))
        end as purchase_open_quantity
        , case
            when coalesce(purchasing_document_overview.delivery_completed, 'n') <> ' '
                and coalesce(purchasing_document_overview.received_quantity, 0) < purchasing_document_item.purchase_order_quantity
                then cast(1 as numeric(28,6))
            else cast(0 as numeric(28,6))
        end as purchase_item_open_count
        , case
            when coalesce(purchasing_document_overview.delivery_completed, 'n') <> ' '
                or purchasing_document_overview.received_quantity >= purchasing_document_item.purchase_order_quantity
                then cast(1 as numeric(28,6))
            else cast(0 as numeric(28,6))
        end as purchase_item_closed_count
        

        
        , date_diff('day', purchasing_document_header.purchasing_document_date::timestamp, purchasing_document_overview.latest_goods_receive_date::timestamp ) as purchase_deliver_late_days
        , case
            when purchasing_document_overview.delivery_completed is not null
                then cast(0 as numeric(28,6))
            else (
                purchasing_document_item.net_order_po_currency_val *
                (
                    case
                        when purchasing_document_header.exchange_rate < 0
                            then -1 / purchasing_document_header.exchange_rate
                        else purchasing_document_header.exchange_rate
                    end
                )
            ) - purchasing_document_overview.received_value_in_local_curr
        end as purchase_open_amount
        

        
        , date_diff('day', purchasing_document_schedule_total.lastest_scheduled_delivery_date::timestamp, purchasing_document_overview.latest_goods_receive_date::timestamp ) as purchase_late_lead_days
        , case
            when purchasing_document_overview.latest_goods_receive_date > purchasing_document_schedule_total.lastest_scheduled_delivery_date
                then purchasing_document_overview.received_quantity
            else cast(0 as numeric(28,6))
        end as purchase_late_quantity
        , case
            when purchasing_document_overview.latest_goods_receive_date > purchasing_document_schedule_total.lastest_scheduled_delivery_date
                then purchasing_document_overview.received_value_in_local_curr
            else cast(0 as numeric(28,6))
        end as purchase_late_amount
        , case
            when purchasing_document_overview.latest_goods_receive_date > purchasing_document_schedule_total.lastest_scheduled_delivery_date
                then cast(1 as numeric(28,6))
            else cast(0 as numeric(28,6))
        end as purchase_item_late_count
        

        , cast(1 as numeric(28,6)) as purchase_order_item_count

    from purchasing_document_item

    
    left join purchasing_document_header
        on purchasing_document_header.purchasing_document_id = purchasing_document_item.purchasing_document_id
    

    
    left join company
        on company.company_code_id = purchasing_document_header.company_code_id
    

    
    left join purchasing_document_overview
        on purchasing_document_overview.purchasing_document_id = purchasing_document_item.purchasing_document_id
        and purchasing_document_overview.purchasing_document_item_id = purchasing_document_item.purchasing_document_item_id
    

    
    left join purchasing_document_schedule_total
        on purchasing_document_schedule_total.purchasing_document_id = purchasing_document_item.purchasing_document_id
        and purchasing_document_schedule_total.purchasing_document_item_id = purchasing_document_item.purchasing_document_item_id
    
)

select *
from final
