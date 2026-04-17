with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__application_tmp"

),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    applied_at
    
 , 
    cast(null as integer) as 
    
    candidate_id
    
 , 
    cast(null as integer) as 
    
    credited_to_user_id
    
 , 
    cast(null as integer) as 
    
    current_stage_id
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    is_deleted
    
 , 
    cast(null as timestamp) as 
    
    last_activity_at
    
 , 
    cast(null as TEXT) as 
    
    location_address
    
 , 
    cast(null as boolean) as 
    
    prospect
    
 , 
    cast(null as integer) as 
    
    prospect_owner_id
    
 , 
    cast(null as integer) as 
    
    prospect_pool_id
    
 , 
    cast(null as integer) as 
    
    prospect_stage_id
    
 , 
    cast(null as timestamp) as 
    
    rejected_at
    
 , 
    cast(null as integer) as 
    
    rejected_reason_id
    
 , 
    cast(null as integer) as 
    
    source_id
    
 , 
    cast(null as TEXT) as 
    
    status
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation


        
        
    from base
),

final as (

    select
        source_relation,
        _fivetran_synced,
        cast(applied_at as timestamp) as applied_at,
        cast(candidate_id as TEXT) as candidate_id,
        cast(credited_to_user_id as TEXT) as credited_to_user_id,
        cast(current_stage_id as TEXT) as current_stage_id,
        cast(id as TEXT) as application_id,
        cast(last_activity_at as timestamp) as last_activity_at,
        location_address,
        prospect as is_prospect,
        cast(prospect_owner_id as TEXT) as prospect_owner_user_id,
        cast(prospect_pool_id as TEXT) as prospect_pool_id,
        cast(prospect_stage_id as TEXT) as prospect_stage_id,
        cast(rejected_at as timestamp) as rejected_at,
        cast(rejected_reason_id as TEXT) as rejected_reason_id,
        cast(source_id as TEXT) as source_id,
        status

        

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select * from final
