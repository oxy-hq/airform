with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__hiring_team_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    job_id
    
 , 
    cast(null as TEXT) as 
    
    role
    
 , 
    cast(null as integer) as 
    
    user_id
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation


    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        cast(job_id as TEXT) as job_id,
        role,
        cast(user_id as TEXT) as user_id
        
    from fields
)

select * from final
