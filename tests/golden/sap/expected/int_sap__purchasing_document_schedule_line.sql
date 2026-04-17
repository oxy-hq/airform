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
