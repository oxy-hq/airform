with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__scheduled_interview_tmp"

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
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as timestamp) as 
    
    ends
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    interview_id
    
 , 
    cast(null as TEXT) as 
    
    location
    
 , 
    cast(null as integer) as 
    
    organizer_id
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as timestamp) as 
    
        
            
            "end"
            
        
    
 , 
    cast(null as timestamp) as 
    
    start
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

        
    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        cast(application_id as TEXT) as application_id,
        cast(created_at as timestamp) as created_at,
        cast(coalesce(ends,
        end
        
        ) as timestamp) as end_at,
        cast(id as TEXT) as scheduled_interview_id,
        cast(interview_id as TEXT) as interview_id,
        location,
        cast(organizer_id as TEXT) as organizer_user_id,

        cast(
        start
        
        as timestamp) as start_at,

        status,
        cast(updated_at as timestamp) as last_updated_at

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
