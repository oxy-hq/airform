with base as (
    select 
    from "sap"."main_sap"."stg_sap__dd07l_tmp"
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
    
    as4local
    
 , 
    cast(null as TEXT) as 
    
    as4vers
    
 , 
    cast(null as TEXT) as 
    
    domvalue_l
    
 , 
    cast(null as TEXT) as 
    
    domname
    
 , 
    cast(null as TEXT) as 
    
    valpos
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 


    from base
),

final as (
    select
        as4local,
        as4vers,
        domname,
        valpos,
        domvalue_l,
        hvr_change_time,
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_synced
    from fields
)

select *
from final
