with base as (

    select * 
    from "greenhouse"."main_stg_greenhouse"."stg_greenhouse__scorecard_attribute_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    index
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    note
    
 , 
    cast(null as TEXT) as 
    
    rating
    
 , 
    cast(null as integer) as 
    
    scorecard_id
    
 , 
    cast(null as TEXT) as 
    
    type
    
 


        
, 'greenhouse' || '.'|| 'greenhouse_integration_tests' as source_relation

    from base
),

final as (
    
    select
        source_relation,
        _fivetran_synced,
        index,
        name as attribute_name,
        note,
        rating,
        cast(scorecard_id as TEXT) as scorecard_id,
        type as attribute_category

    from fields
)

select * from final
