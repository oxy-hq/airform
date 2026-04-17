with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__scheduled_interviewer_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    interviewer_id
    
 , 
    cast(null as integer) as 
    
    scheduled_interview_id
    
 , 
    cast(null as integer) as 
    
    scorecard_id
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        cast(interviewer_id as TEXT) as interviewer_user_id,
        cast(scheduled_interview_id as TEXT) as scheduled_interview_id,
        cast(scorecard_id as TEXT) as scorecard_id

    from fields
)

select * from final
