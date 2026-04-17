--To disable this model, set the using_schedules variable within your dbt_project.yml file to False.


with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_schedule_tmp"

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
    
    schedule_id
    
 , 
    cast(null as integer) as 
    
    ticket_id
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation

        
    from base
),

final as (
    
    select 
        ticket_id,
        cast(created_at as timestamp) as created_at,
        cast(schedule_id as TEXT) as schedule_id, --need to convert from numeric to string for downstream models to work properly
        source_relation
    from fields
)

select * 
from final
