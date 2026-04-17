with base as (

    select * 
    from "netsuite"."main_netsuite_source"."stg_netsuite2__classes_tmp"
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
    
    externalid
    
 , 
    cast(null as TEXT) as 
    
    fullname
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    isinactive
    
 , 
    cast(null as TEXT) as 
    
    name
    
 



        
, 'netsuite' || '.'|| 'netsuite_integrations_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        id as class_id,
        externalid as class_external_id,
        name,
        fullname as full_name,
        isinactive = 'T' as is_inactive,
        _fivetran_deleted

        --The below macro adds the fields defined within your classes_pass_through_columns variable into the staging model
        







    from fields
)

select * 
from final
