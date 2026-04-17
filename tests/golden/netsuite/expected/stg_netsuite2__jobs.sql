with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__jobs_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    customer
    
 , 
    cast(null as integer) as 
    
    defaultbillingaddress
    
 , 
    cast(null as integer) as 
    
    defaultshippingaddress
    
 , 
    cast(null as TEXT) as 
    
    entityid
    
 , 
    cast(null as TEXT) as 
    
    externalid
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    parent
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation, 
        _fivetran_synced,
        id as job_id,
        externalid as job_external_id,
        customer as customer_id,
        entityid as entity_id,
        defaultbillingaddress as billing_address_id,
        defaultshippingaddress as shipping_address_id,
        parent as parent_id
    from fields
)

select *
from final
