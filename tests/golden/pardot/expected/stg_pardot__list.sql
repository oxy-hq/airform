with base as (

    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__list_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    is_crm_visible
    
 , 
    cast(null as boolean) as 
    
    is_dynamic
    
 , 
    cast(null as boolean) as 
    
    is_public
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    title
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 


        
, 'pardot' || '.'|| 'pardot_integration_tests' as source_relation


    from base
),

final as (

    select
        source_relation,
        id as list_id,
        name,
        description,
        title,
        is_crm_visible,
        is_public,
        is_dynamic,
        created_at as created_timestamp,
        updated_at as updated_timestamp,
        _fivetran_synced
    from fields

)

select * from final
