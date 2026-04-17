with base as (
    select 
    from "sap"."main_sap"."stg_sap__makt_tmp"
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
    
    maktx
    
 , 
    cast(null as TEXT) as 
    
    mandt
    
 , 
    cast(null as TEXT) as 
    
    matnr
    
 , 
    cast(null as TEXT) as 
    
    spras
    
 


    from base
),

final as (
    select
        maktx,
        cast(mandt as TEXT) as mandt,
        cast(matnr as TEXT) as matnr,
        spras,
        _fivetran_rowid,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select *
from final
