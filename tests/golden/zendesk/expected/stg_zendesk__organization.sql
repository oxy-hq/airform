with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__organization_tmp"

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_zendesk/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_zendesk/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    details
    
 , 
    cast(null as integer) as 
    
    external_id
    
 , 
    cast(null as integer) as 
    
    group_id
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    notes
    
 , 
    cast(null as boolean) as 
    
    shared_comments
    
 , 
    cast(null as boolean) as 
    
    shared_tickets
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 , 
    cast(null as TEXT) as 
    
    url
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select 
        id as organization_id,
        created_at,
        updated_at,
        details,
        name,
        external_id,
        source_relation

        





    from fields
)

select * 
from final
