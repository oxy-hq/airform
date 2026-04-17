with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__office_tmp"

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
    
    external_id
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    location_name
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    parent_id
    
 , 
    cast(null as integer) as 
    
    primary_contact_user_id
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        cast(external_id as TEXT) as external_office_id,
        cast(id as TEXT) as office_id,
        location_name,
        name as office_name,
        cast(parent_id as TEXT) as parent_office_id,
        cast(primary_contact_user_id as TEXT) as primary_contact_user_id
        
    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
