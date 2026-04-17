with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__entities_tmp"
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
    
    contact
    
 , 
    cast(null as integer) as 
    
    customer
    
 , 
    cast(null as integer) as 
    
    employee
    
 , 
    cast(null as TEXT) as 
    
    entitytitle
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    isperson
    
 , 
    cast(null as integer) as 
    
    parent
    
 , 
    cast(null as integer) as 
    
    project
    
 , 
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as integer) as 
    
    vendor
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as entity_id,
        parent as parent_id,
        entitytitle as entity_name,
        type as entity_type,
        isperson = 'T' as is_person,
        contact as contact_id,
        customer as customer_id,
        employee as employee_id,
        project as job_id,
        vendor as vendor_id

        --The below macro adds the fields defined within your entities_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
