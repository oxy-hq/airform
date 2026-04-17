--To disable this model, set the using_schedules variable within your dbt_project.yml file to False.


with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__schedule_tmp"

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
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    end_time
    
 , 
    cast(null as integer) as 
    
    end_time_utc
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    start_time
    
 , 
    cast(null as integer) as 
    
    start_time_utc
    
 , 
    cast(null as TEXT) as 
    
    time_zone
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select 
        cast(id as TEXT) as schedule_id, --need to convert from numeric to string for downstream models to work properly
        end_time,
        start_time,
        name as schedule_name,
        created_at,
        time_zone,
        source_relation
        
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
