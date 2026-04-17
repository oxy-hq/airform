--To disable this model, set the using_ticket_sla_policy variable within your dbt_project.yml file to False.


with base as (

    select *
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_sla_policy_tmp"

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
    
    policy_applied_at
    
 , 
    cast(null as integer) as 
    
    sla_policy_id
    
 , 
    cast(null as integer) as 
    
    ticket_id
    
 



        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (

    select
        source_relation,
        ticket_id,
        sla_policy_id,
        cast(policy_applied_at as timestamp) as policy_applied_at,
        cast(_fivetran_synced as timestamp) as _fivetran_synced

    from fields
)

select *
from final
