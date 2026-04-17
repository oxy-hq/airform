with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__activity_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    body
    
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
    
    subject
    
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
        body,
        cast(candidate_id as TEXT) as candidate_id,
        cast(created_at as timestamp) as occurred_at,
        cast(id as TEXT) as activity_id,
        subject,
        cast(user_id as TEXT) as user_id

    from fields
)

select * from final
