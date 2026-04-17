with base as (

    select 
    from "sap"."main_sap"."stg_sap__matdoc_extract_tmp"
),

fields as (

    select
        
    cast(null as numeric(28,6)) as 
    
    _cwm_consumption_qty
    
 , 
    cast(null as TEXT) as 
    
    _cwm_meins
    
 , 
    cast(null as TEXT) as 
    
    _cwm_meins_sid
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_stock_qty_l1
    
 , 
    cast(null as numeric(28,6)) as 
    
    _cwm_stock_qty_l2
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as boolean) as 
    
    _fivetran_sap_archived
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as TEXT) as 
    
    charg_sid
    
 , 
    cast(null as numeric(28,6)) as 
    
    consumption_qty
    
 , 
    cast(null as date) as 
    
    cpudt_l1
    
 , 
    cast(null as date) as 
    
    cpudt_l2
    
 , 
    cast(null as TEXT) as 
    
    disub_owner_sid
    
 , 
    cast(null as TEXT) as 
    
    gjper
    
 , 
    cast(null as TEXT) as 
    
    gjper_curr_per
    
 , 
    cast(null as TEXT) as 
    
    kunnr_sid
    
 , 
    cast(null as TEXT) as 
    
    kzbws
    
 , 
    cast(null as TEXT) as 
    
    lbbsa_sid
    
 , 
    cast(null as TEXT) as 
    
    lgort_sid
    
 , 
    cast(null as TEXT) as 
    
    lifnr_sid
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mat_kdauf
    
 , 
    cast(null as TEXT) as 
    
    mat_kdpos
    
 , 
    cast(null as TEXT) as 
    
    mat_pspnr
    
 , 
    cast(null as TEXT) as 
    
    matbf
    
 , 
    cast(null as TEXT) as 
    
    meins
    
 , 
    cast(null as TEXT) as 
    
    periv
    
 , 
    cast(null as TEXT) as 
    
    record_type
    
 , 
    cast(null as TEXT) as 
    
    resourcename_sid
    
 , 
    cast(null as TEXT) as 
    
    sobkz
    
 , 
    cast(null as TEXT) as 
    
    stock_ind_l2
    
 , 
    cast(null as numeric(28,6)) as 
    
    stock_qty_l1
    
 , 
    cast(null as numeric(28,6)) as 
    
    stock_qty_l2
    
 , 
    cast(null as numeric(28,6)) as 
    
    stock_vkwrt_l1
    
 , 
    cast(null as numeric(28,6)) as 
    
    stock_vkwrt_l2
    
 , 
    cast(null as TEXT) as 
    
    waers
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 , 
    cast(null as TEXT) as 
    
    xobew
    
 


    from base
),

final as (
    select
        _cwm_consumption_qty,
        _cwm_meins,
        _cwm_meins_sid,
        _cwm_stock_qty_l1,
        _cwm_stock_qty_l2,
        _fivetran_deleted,
        _fivetran_sap_archived,
        _fivetran_synced,
        cast(bukrs as TEXT) as bukrs,
        cast(charg_sid as TEXT) as charg_sid,
        consumption_qty,
        cpudt_l1,
        cpudt_l2,
        disub_owner_sid,
        gjper,
        gjper_curr_per,
        kunnr_sid,
        kzbws,
        cast(lbbsa_sid as TEXT) as lbbsa_sid,
        cast(lgort_sid as TEXT) as lgort_sid,
        lifnr_sid,
        cast(mandt as TEXT) as mandt,
        mat_kdauf,
        mat_kdpos,
        mat_pspnr,
        cast(matbf as TEXT) as matbf,
        meins,
        periv,
        record_type,
        resourcename_sid,
        cast(sobkz as TEXT) as sobkz,
        cast(stock_ind_l2 as TEXT) as stock_ind_l2,
        stock_qty_l1,
        stock_qty_l2,
        stock_vkwrt_l1,
        stock_vkwrt_l2,
        waers,
        cast(werks as TEXT) as werks,
        xobew
    from fields
)

select *
from final
