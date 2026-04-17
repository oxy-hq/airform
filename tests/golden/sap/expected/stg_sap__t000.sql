with base as (
    select 
    from "sap"."main_sap"."stg_sap__t000_tmp"
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
    
    logsys
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 


    from base
),

final as (
    select
        cast(mandt as TEXT) as mandt,
        cast(logsys as TEXT) as logsys,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
