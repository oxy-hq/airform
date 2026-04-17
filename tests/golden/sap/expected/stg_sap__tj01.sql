with base as (
    select 
    from "sap"."main_sap"."stg_sap__tj01_tmp"
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
    
    vrgng
    
 , 
    cast(null as TEXT) as 
    
    wtkat
    
 , 
    cast(null as TEXT) as 
    
    xcosp
    
 , 
    cast(null as TEXT) as 
    
    xcoss
    
 


    from base
),

final as (
    select
        cast(vrgng as TEXT) as vrgng,
        cast(wtkat as TEXT) as wtkat,
        cast(xcosp as TEXT) as xcosp,
        cast(xcoss as TEXT) as xcoss,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
