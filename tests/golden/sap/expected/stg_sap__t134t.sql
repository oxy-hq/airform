with base as (
    select 
    from "sap"."main_sap"."stg_sap__t134t_tmp"
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
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    mtart
    
 , 
    cast(null as TEXT) as 
    
    mtbez
    
 , 
    cast(null as TEXT) as 
    
    spras
    
 


    from base
),

final as (
    select
        cast(mandt as TEXT) as mandt,
        mtart,
        mtbez,
        spras,
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_rowid
    from fields
)

select *
from final
