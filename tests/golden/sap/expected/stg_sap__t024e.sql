with base as (
    select 
    from "sap"."main_sap"."stg_sap__t024e_tmp"
),

fields as (
    select
        
    cast(null as TEXT) as 
    
    ekorg
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    ekotx
    
 , 
    cast(null as TEXT) as 
    
    txfus
    
 , 
    cast(null as TEXT) as 
    
    txgru
    
 , 
    cast(null as TEXT) as 
    
    bpeff
    
 , 
    cast(null as TEXT) as 
    
    txkop
    
 , 
    cast(null as TEXT) as 
    
    kalse
    
 , 
    cast(null as TEXT) as 
    
    txadr
    
 , 
    cast(null as TEXT) as 
    
    mkals
    
 , 
    cast(null as TEXT) as 
    
    bukrs
    
 , 
    cast(null as TEXT) as 
    
    bukrs_ntr
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    _fivetran_sap_archived
    
 


    from base
),

final as (
    select
        ekorg,
        cast(mandt as TEXT) as mandt,
        ekotx,
        txfus,
        txgru,
        bpeff,
        txkop,
        kalse,
        txadr,
        mkals,
        bukrs,
        bukrs_ntr,
        _fivetran_deleted,
        _fivetran_synced,
        _fivetran_sap_archived
    from fields
)

select *
from final
