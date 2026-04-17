with base as (

    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__opportunity_prospect_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    opportunity_id
    
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
        opportunity_id,
        prospect_id,
        updated_at as updated_timestamp,
        _fivetran_synced,
        md5(cast(coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(opportunity_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(prospect_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as opportunity_prospect_id
    from fields

)

select * from final
