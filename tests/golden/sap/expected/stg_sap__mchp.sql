with base as (
    select 
    from "sap"."main_sap"."stg_sap__mchp_tmp"
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
    
    charg
    
 , 
    cast(null as TEXT) as 
    
    dokar
    
 , 
    cast(null as TEXT) as 
    
    doknr
    
 , 
    cast(null as TEXT) as 
    
    doktl
    
 , 
    cast(null as TEXT) as 
    
    dokvr
    
 , 
    cast(null as TEXT) as 
    
    ebrid
    
 , 
    cast(null as TEXT) as 
    
    ebrstatus
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as date) as 
    
    valdat
    
 , 
    cast(null as TEXT) as 
    
    vers_stat
    
 , 
    cast(null as TEXT) as 
    
    version
    
 , 
    cast(null as TEXT) as 
    
    werks
    
 


    from base
),

final as (
    select
        charg,
        dokar,
        doknr,
        doktl,
        dokvr,
        ebrid,
        ebrstatus,
        mandt,
        matnr,
        valdat,
        vers_stat,
        version,
        werks,
        _fivetran_deleted,
        _fivetran_sap_archived,
        _fivetran_synced
    from fields
)

select *
from final
