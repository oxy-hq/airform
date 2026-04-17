with base as (

    select * 
    from "jira"."main_jira_source"."stg_jira__status_category_tmp"
),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 


        
, 'jira' || '.'|| 'jira_integration_tests' as source_relation

    from base
),

final as (

    select
        source_relation,
        id as status_category_id,
        name as status_category_name
    from fields
)

select * 
from final
