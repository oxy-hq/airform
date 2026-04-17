with base as (

    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__opportunity_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    campaign_id
    
 , 
    cast(null as timestamp) as 
    
    closed_at
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    probability
    
 , 
    cast(null as TEXT) as 
    
    stage
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as float) as 
    
    value
    
 


        
, 'pardot' || '.'|| 'pardot_integration_tests' as source_relation


    from base
),

final as (

    select
        source_relation,
        id as opportunity_id,
        campaign_id,
        created_at as created_timestamp,
        updated_at as updated_timestamp,
        name as opportunity_name,
        probability,
        status as opportunity_status,
        stage,
        type as opportunity_type,
        value as amount,
        _fivetran_synced,
        closed_at as closed_timestamp
    from fields

)

select * from final
