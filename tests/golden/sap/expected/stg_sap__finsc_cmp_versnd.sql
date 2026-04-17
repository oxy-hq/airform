with base as (
    select 
    from "sap"."main_sap"."stg_sap__finsc_cmp_versnd_tmp"
),

fields as (
    select
        
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
    
    field_name_buzei
    
 , 
    cast(null as TEXT) as 
    
    field_name_pafbtr_add
    
 , 
    cast(null as TEXT) as 
    
    field_name_pafbtr_subtract
    
 , 
    cast(null as TEXT) as 
    
    field_name_pagbtr_add
    
 , 
    cast(null as TEXT) as 
    
    field_name_pagbtr_subtract
    
 , 
    cast(null as TEXT) as 
    
    field_name_refbz
    
 , 
    cast(null as TEXT) as 
    
    field_name_wkfbtr_add
    
 , 
    cast(null as TEXT) as 
    
    field_name_wkfbtr_subtract
    
 , 
    cast(null as TEXT) as 
    
    field_name_wkgbtr_add
    
 , 
    cast(null as TEXT) as 
    
    field_name_wkgbtr_subtract
    
 , 
    cast(null as TEXT) as 
    
    field_name_wogbtr_add
    
 , 
    cast(null as TEXT) as 
    
    field_name_wogbtr_subtract
    
 , 
    cast(null as TEXT) as 
    
    field_name_wtgbtr_add
    
 , 
    cast(null as TEXT) as 
    
    field_name_wtgbtr_subtract
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    rldnr
    
 , 
    cast(null as TEXT) as 
    
    set_to_zero
    
 , 
    cast(null as TEXT) as 
    
    versn
    
 


    from base
),

final as (
    select
        cast(mandt as TEXT) as mandt,
        cast(bukrs as TEXT) as bukrs,
        cast(rldnr as TEXT) as rldnr,
        cast(versn as TEXT) as versn,
        cast(field_name_buzei as TEXT) as field_name_buzei,
        cast(field_name_wtgbtr_add as TEXT) as field_name_wtgbtr_add,
        cast(field_name_wtgbtr_subtract as TEXT) as field_name_wtgbtr_subtract,
        cast(set_to_zero as TEXT) as set_to_zero,
        cast(field_name_wogbtr_add as TEXT) as field_name_wogbtr_add,
        cast(field_name_wogbtr_subtract as TEXT) as field_name_wogbtr_subtract,
        cast(field_name_wkgbtr_add as TEXT) as field_name_wkgbtr_add,
        cast(field_name_wkgbtr_subtract as TEXT) as field_name_wkgbtr_subtract,
        cast(field_name_wkfbtr_add as TEXT) as field_name_wkfbtr_add,
        cast(field_name_wkfbtr_subtract as TEXT) as field_name_wkfbtr_subtract,
        cast(field_name_pagbtr_add as TEXT) as field_name_pagbtr_add,
        cast(field_name_pagbtr_subtract as TEXT) as field_name_pagbtr_subtract,
        cast(field_name_refbz as TEXT) as field_name_refbz,
        cast(field_name_pafbtr_add as TEXT) as field_name_pafbtr_add,
        cast(field_name_pafbtr_subtract as TEXT) as field_name_pafbtr_subtract,
        _fivetran_sap_archived,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
