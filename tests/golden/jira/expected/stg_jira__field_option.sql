with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__field_option_tmp"
),

fields as (

    select
        
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    parent_id
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    name
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as field_id,
        parent_id as parent_field_id,
        name as field_option_name
    from fields
)

select * 
from final
