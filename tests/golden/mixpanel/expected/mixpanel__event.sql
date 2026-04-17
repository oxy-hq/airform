with  __dbt__cte__stg_mixpanel__event as (


with events as (

    select 
        
*
/* No columns were returned. Maybe the relation doesn't exist yet 
or all columns were excluded. This star is only output during  
dbt compile, and exists to keep SQLFluff happy. */
            
    from "mixpanel"."mixpanel_integration_tests_3"."event"

),

fields as (

    select
        cast( date_trunc('day', time) as date) as date_day,
        lower(name) as event_type,
        cast(time as timestamp ) as occurred_at,

        -- pulls default properties and renames (see macros/staging_columns)
        -- columns missing from your source table will be completely NULL   
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    _fivetran_id
    
 , 
    cast(null as TEXT) as app_session_length , 
    cast(null as TEXT) as 
    
    app_build_number
    
 , 
    cast(null as TEXT) as app_version , 
    cast(null as boolean) as has_bluetooth_enabled , 
    cast(null as TEXT) as 
    
    bluetooth_version
    
 , 
    cast(null as TEXT) as device_brand , 
    cast(null as TEXT) as 
    
    browser
    
 , 
    cast(null as integer) as 
    
    browser_version
    
 , 
    cast(null as TEXT) as wireless_carrier , 
    cast(null as TEXT) as 
    
    city
    
 , 
    cast(null as TEXT) as 
    
    current_url
    
 , 
    cast(null as TEXT) as device_name , 
    cast(null as TEXT) as 
    
    device_id
    
 , 
    cast(null as TEXT) as people_id , 
    cast(null as TEXT) as people_id_before_identified , 
    cast(null as TEXT) as google_play_service_status , 
    cast(null as boolean) as has_near_field_communication , 
    cast(null as boolean) as 
    
    has_telephone
    
 , 
    cast(null as TEXT) as 
    
    initial_referrer
    
 , 
    cast(null as TEXT) as 
    
    initial_referring_domain
    
 , 
    cast(null as TEXT) as 
    
    insert_id
    
 , 
    cast(null as TEXT) as mixpanel_library_version , 
    cast(null as TEXT) as device_manufacturer , 
    cast(null as TEXT) as device_model , 
    cast(null as TEXT) as country_code , 
    cast(null as TEXT) as referrer_keywords , 
    cast(null as TEXT) as mixpanel_library , 
    cast(null as integer) as 
    
    mp_processing_time_ms
    
 , 
    cast(null as TEXT) as event_type_original_casing , 
    cast(null as TEXT) as 
    
    os
    
 , 
    cast(null as TEXT) as 
    
    os_version
    
 , 
    cast(null as TEXT) as event_properties , 
    cast(null as TEXT) as network_type , 
    cast(null as TEXT) as 
    
    referrer
    
 , 
    cast(null as TEXT) as 
    
    referring_domain
    
 , 
    cast(null as TEXT) as 
    
    region
    
 , 
    cast(null as integer) as screen_pixel_density , 
    cast(null as integer) as 
    
    screen_height
    
 , 
    cast(null as integer) as 
    
    screen_width
    
 , 
    cast(null as TEXT) as 
    
    search_engine
    
 , 
    cast(null as boolean) as has_wifi_connected 



        
, 'mixpanel' || '.'|| 'mixpanel_integration_tests_3' as source_relation

        
        -- custom properties as specified in your dbt_project.yml
        




        
    from events

    where true

)

select * from fields
), stg_event as (

    select *
    from __dbt__cte__stg_mixpanel__event

    where 

    
    -- limit date range on the first run / refresh
    occurred_at >= '2010-01-01' 
    
),

dupes as (

    select 
        md5(cast(coalesce(cast(insert_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(people_id as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(event_type as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(date_day as TEXT), '_dbt_utils_surrogate_key_null_') || '-' || coalesce(cast(source_relation as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as unique_event_id,
        *,
        
        -- aligned with mixpanel' s deduplication method: https://developer.mixpanel.com/reference/http#event-deduplication
        -- de-duping on calendar day + insert_id but also on people_id + event_type to reduce the rate of false positives 
        -- using calendar day as mixpanel de-duplicates events at the end of each day
        row_number() over(partition by insert_id, people_id, event_type, date_day  order by mp_processing_time_ms asc) as nth_event_record
        
        from stg_event

),

dedupe as (

    select *
    from dupes
    where nth_event_record = 1

),

pivot_properties as (

    select 
        *,
        current_date as dbt_run_date
        

    from dedupe
)

select * from pivot_properties
