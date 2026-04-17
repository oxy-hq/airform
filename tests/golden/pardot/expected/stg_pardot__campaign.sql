with base as (

    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__campaign_tmp"

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
    
    cost
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 


        
, 'pardot' || '.'|| 'pardot_integration_tests' as source_relation


    from base
    where not coalesce(_fivetran_deleted, false)
),

final as (

    select
        source_relation,
        id as campaign_id,
        name as campaign_name,
        cost,
        _fivetran_deleted,
        _fivetran_synced
    from fields
)

select * from final
