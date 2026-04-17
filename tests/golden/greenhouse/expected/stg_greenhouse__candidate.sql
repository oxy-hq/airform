with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__candidate_tmp"

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
    
    company
    
 , 
    cast(null as integer) as 
    
    coordinator_id
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    first_name
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    is_private
    
 , 
    cast(null as timestamp) as 
    
    last_activity
    
 , 
    cast(null as TEXT) as 
    
    last_name
    
 , 
    cast(null as integer) as 
    
    new_candidate_id
    
 , 
    cast(null as integer) as 
    
    recruiter_id
    
 , 
    cast(null as TEXT) as 
    
    title
    
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
        company as current_company,
        cast(coordinator_id as TEXT) as coordinator_user_id,
        cast(created_at as timestamp) as created_at,
        first_name || ' ' || last_name as full_name,
        cast(id as TEXT) as candidate_id,
        is_private,
        cast(last_activity as timestamp) as last_activity_at,
        cast(new_candidate_id as TEXT) as new_candidate_id,
        cast(recruiter_id as TEXT) as recruiter_user_id,
        title as current_title,
        cast(updated_at as timestamp) as last_updated_at

        

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
