with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_field_history_tmp"

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
    cast(null as TEXT) as 
    
    field_name
    
 , 
    cast(null as integer) as 
    
    ticket_id
    
 , 
    cast(null as timestamp) as 
    
    updated
    
 , 
    cast(null as integer) as 
    
    user_id
    
 , 
    cast(null as TEXT) as 
    
    value
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select 
        ticket_id,
        field_name,
        cast(updated as timestamp) as valid_starting_at,
        cast(lead(updated) over (partition by ticket_id, field_name  order by updated) as timestamp) as valid_ending_at,
        value,
        user_id,
        source_relation
        
    from fields
)

select * 
from final
