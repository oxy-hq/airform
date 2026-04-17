--To disable this model, set the using_schedules variable within your dbt_project.yml file to False.


with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__time_zone_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    standard_offset
    
 , 
    cast(null as TEXT) as 
    
    time_zone
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select 
        standard_offset,
        time_zone,
        -- the standard_offset is a string written as [+/-]HH:MM
        -- let's convert it to an integer value of minutes
        cast( 
    string_split(standard_offset, ':')[ 1 ]
 as integer ) * 60 +
            (cast( 
    string_split(standard_offset, ':')[ 2 ]
 as integer ) *
                (case when standard_offset like '-%' then -1 else 1 end) ) as standard_offset_minutes,
        source_relation
    
    from fields
)

select * 
from final
