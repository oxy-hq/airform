with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__user_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as boolean) as 
    
    disabled
    
 , 
    cast(null as TEXT) as 
    
    employee_id
    
 , 
    cast(null as TEXT) as 
    
    first_name
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    last_name
    
 , 
    cast(null as boolean) as 
    
    site_admin
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

        
    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        cast(created_at as timestamp) as created_at,
        disabled as is_disabled,
        cast(employee_id as TEXT) as employee_id, -- external
        first_name || ' ' || last_name as full_name,
        cast(id as TEXT) as user_id,
        site_admin as is_site_admin,
        cast(updated_at as timestamp) as last_updated_at

    from fields

)

select * from final
