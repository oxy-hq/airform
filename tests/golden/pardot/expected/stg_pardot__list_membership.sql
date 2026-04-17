with base as (

    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__list_membership_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    list_id
    
 , 
    cast(null as boolean) as 
    
    opted_out
    
 , 
    cast(null as integer) as 
    
    prospect_id
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 


        
, 'pardot' || '.'|| 'pardot_integration_tests' as source_relation


    from base
),

final as (

    select
        source_relation,
        id as list_membership_id,
        prospect_id,
        list_id,
        created_at as created_timestamp,
        updated_at as updated_timestamp,
        opted_out as has_opted_out,
        _fivetran_synced
    from fields
)

select * from final
