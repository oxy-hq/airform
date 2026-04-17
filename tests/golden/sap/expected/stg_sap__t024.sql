with base as (
    select 
    from "sap"."main_sap"."stg_sap__t024_tmp"
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
    
    _fivetran_sap_archived
    
 , 
    cast(null as TEXT) as 
    
    ekgrp
    
 , 
    cast(null as TEXT) as 
    
    eknam
    
 , 
    cast(null as TEXT) as 
    
    ektel
    
 , 
    cast(null as TEXT) as 
    
    ldest
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    smtp_addr
    
 , 
    cast(null as TEXT) as 
    
    tel_extens
    
 , 
    cast(null as TEXT) as 
    
    tel_number
    
 , 
    cast(null as TEXT) as 
    
    telfx
    
 


    from base
),

final as (
    select
        _fivetran_deleted,
        _fivetran_rowid,
        _fivetran_synced,
        _fivetran_sap_archived,
        ekgrp,
        eknam,
        ektel,
        ldest,
        cast(mandt as TEXT) as mandt,
        smtp_addr,
        tel_extens,
        tel_number,
        telfx
    from fields
)

select *
from final
