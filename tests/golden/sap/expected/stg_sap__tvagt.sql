with base as (
    select 
    from "sap"."main_sap"."stg_sap__tvagt_tmp"
),

fields as (
    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as numeric(28,6)) as 
    
    _fivetran_rowid
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    abgru
    
 , 
    cast(null as TEXT) as 
    
    bezei
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    spras
    
 


    from base
),

final as (
    select
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_synced,
        abgru,
        bezei,
        cast(mandt as TEXT) as mandt,
        spras
    from fields
)

select *
from final
