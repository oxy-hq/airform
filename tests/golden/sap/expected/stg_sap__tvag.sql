with base as (
    select 
    from "sap"."main_sap"."stg_sap__tvag_tmp"
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
    
    dragr
    
 , 
    cast(null as TEXT) as 
    
    ep_off
    
 , 
    cast(null as TEXT) as 
    
    fk_erl
    
 , 
    cast(null as TEXT) as 
    
    fsh_pqr_spec
    
 , 
    cast(null as TEXT) as 
    
    hvr_change_time
    
 , 
    cast(null as integer) as 
    
    hvr_is_deleted
    
 , 
    cast(null as TEXT) as 
    
    kowrr
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 


    from base
),

final as (
    select
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_synced,
        abgru,
        dragr,
        ep_off,
        fk_erl,
        fsh_pqr_spec,
        hvr_change_time,
        hvr_is_deleted,
        kowrr,
        mandt
    from fields
)

select *
from final
