with base as (
    select 
    from "sap"."main_sap"."stg_sap__tka01_tmp"
),

fields as (
    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    kokrs
    
 , 
    cast(null as TEXT) as 
    
    logsystem
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    xwbuk
    
 


    from base
),

final as (
    select
        cast(mandt as TEXT) as mandt,
        cast(kokrs as TEXT) as kokrs,
        logsystem,
        cast(xwbuk as TEXT) as xwbuk,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
