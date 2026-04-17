with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__entity_address_tmp"
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
    
    addr1
    
 , 
    cast(null as TEXT) as 
    
    addr2
    
 , 
    cast(null as TEXT) as 
    
    addr3
    
 , 
    cast(null as TEXT) as 
    
    addressee
    
 , 
    cast(null as TEXT) as 
    
    addrtext
    
 , 
    cast(null as TEXT) as 
    
    city
    
 , 
    cast(null as TEXT) as 
    
    country
    
 , 
    cast(null as TEXT) as 
    
    dropdownstate
    
 , 
    cast(null as integer) as 
    
    nkey
    
 , 
    cast(null as TEXT) as 
    
    state
    
 , 
    cast(null as TEXT) as 
    
    zip
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation, 
        _fivetran_synced,
        addr1,
        addr2,
        addr3,
        addressee,
        addrtext as full_address,
        city,
        country,
        coalesce(state, dropdownstate) as state,
        nkey,
        zip as zipcode
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final
