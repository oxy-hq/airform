with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__field_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    is_array
    
 , 
    cast(null as boolean) as 
    
    is_custom
    
 , 
    cast(null as TEXT) as 
    
    name
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        cast(id as TEXT) as field_id,
        is_array,
        is_custom,
        name as field_name,
        _fivetran_synced
    from fields
)

select * 
from final
