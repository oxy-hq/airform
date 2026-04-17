with issue_label as (

    select *
    from "github"."main_github_source"."stg_github__label_tmp"

), macro as (
    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_github/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_github/macros/).

        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
            
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    color
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    is_default
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    url
    
 


        
, 'github' || '.'|| 'github_integration_tests_1' as source_relation


    from issue_label

), fields as (

    select
        source_relation,
        id as label_id,
        _fivetran_synced,
        color,
        description,
        is_default,
        name as label,
        url
    from macro
)

select *
from fields
