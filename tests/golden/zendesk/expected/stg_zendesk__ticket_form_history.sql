--To disable this model, set the using_ticket_form_history variable within your dbt_project.yml file to False.


with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_form_history_tmp"

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_zendesk/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_zendesk/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    active
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    display_name
    
 , 
    cast(null as boolean) as 
    
    end_user_visible
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 



        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select 
        id as ticket_form_id,
        cast(created_at as timestamp) as created_at,
        cast(updated_at as timestamp) as updated_at,
        display_name,
        active as is_active,
        name,
        source_relation
        
    from fields
    where not coalesce(_fivetran_deleted, false)
    
)

select * 
from final
