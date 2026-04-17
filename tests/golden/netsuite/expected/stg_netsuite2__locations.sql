with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__locations_tmp"
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
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    fullname
    
 , 
    cast(null as integer) as 
    
    mainaddress
    
 , 
    cast(null as integer) as 
    
    parent
    
 , 
    cast(null as TEXT) as 
    
    subsidiary
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as location_id,
        name,
        fullname as full_name,
        mainaddress as main_address_id,
        parent as parent_id,
        subsidiary as subsidiary_id

        --The below macro adds the fields defined within your locations_pass_through_columns variable into the staging model
        







    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
