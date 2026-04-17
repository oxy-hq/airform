--To disable this model, set the using_schedules variable within your dbt_project.yml file to False.


with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__daylight_time_tmp"

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
    cast(null as datetime) as 
    
    daylight_end_utc
    
 , 
    cast(null as integer) as 
    
    daylight_offset
    
 , 
    cast(null as datetime) as 
    
    daylight_start_utc
    
 , 
    cast(null as TEXT) as 
    
    time_zone
    
 , 
    cast(null as integer) as 
    
    year
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select 
        daylight_end_utc,
        daylight_offset,
        daylight_start_utc,
        time_zone,
        year,
        daylight_offset * 60 as daylight_offset_minutes,
        source_relation
        
    from fields
)

select * from final
