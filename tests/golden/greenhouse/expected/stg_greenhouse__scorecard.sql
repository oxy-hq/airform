with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__scorecard_tmp"

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
    
    application_id
    
 , 
    cast(null as integer) as 
    
    candidate_id
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    interview
    
 , 
    cast(null as timestamp) as 
    
    interviewed_at
    
 , 
    cast(null as TEXT) as 
    
    overall_recommendation
    
 , 
    cast(null as timestamp) as 
    
    submitted_at
    
 , 
    cast(null as integer) as 
    
    submitted_by_user_id
    
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
        cast(application_id as TEXT) as application_id,
        cast(candidate_id as TEXT) as candidate_id,
        cast(created_at as timestamp) as created_at,
        cast(id as TEXT) as scorecard_id,
        interview as interview_name,
        cast(interviewed_at as timestamp) as interviewed_at,
        overall_recommendation,
        cast(submitted_at as timestamp) as submitted_at,
        cast(submitted_by_user_id as TEXT) as submitted_by_user_id,
        cast(updated_at as timestamp) as last_updated_at

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
