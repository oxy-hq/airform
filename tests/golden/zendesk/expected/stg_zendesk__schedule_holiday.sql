--To disable this model, set the using_schedules or using_holidays variable within your dbt_project.yml file to False.


with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__schedule_holiday_tmp"
),

fields as (

    select
        
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    end_date
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    schedule_id
    
 , 
    cast(null as TEXT) as 
    
    start_date
    
 



        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select
        _fivetran_deleted,
        cast(_fivetran_synced as timestamp ) as _fivetran_synced,
        cast(end_date as timestamp ) as holiday_end_date_at,
        cast(id as TEXT ) as holiday_id,
        name as holiday_name,
        cast(schedule_id as TEXT ) as schedule_id,
        cast(start_date as timestamp ) as holiday_start_date_at,
        source_relation
        
    from fields
)

select *
from final
