with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_tag_tmp"

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
    cast(null as integer) as 
    
    ticket_id
    
 , 
    cast(null as TEXT) as 
    
    tag
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select 
        ticket_id,
        
        tag
         as tags,
        source_relation

    from fields
)

select * 
from final
