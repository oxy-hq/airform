with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__currencies_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    currencyprecision
    
 , 
    cast(null as timestamp) as 
    
    date_deleted
    
 , 
    cast(null as TEXT) as 
    
    displaysymbol
    
 , 
    cast(null as float) as 
    
    exchangerate
    
 , 
    cast(null as TEXT) as 
    
    externalid
    
 , 
    cast(null as integer) as 
    
    fxrateupdatetimezone
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    includeinfxrateupdates
    
 , 
    cast(null as TEXT) as 
    
    isbasecurrency
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as timestamp) as 
    
    lastmodifieddate
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    overridecurrencyformat
    
 , 
    cast(null as TEXT) as 
    
    symbol
    
 , 
    cast(null as integer) as 
    
    symbolplacement
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as currency_id,
        name,
        symbol
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
