with base as (

    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__visitor_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as TEXT) as 
    
    campaign_parameter
    
 , 
    cast(null as TEXT) as 
    
    content_parameter
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    hostname
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    ip_address
    
 , 
    cast(null as TEXT) as 
    
    medium_parameter
    
 , 
    cast(null as integer) as 
    
    page_view_count
    
 , 
    cast(null as integer) as 
    
    prospect_id
    
 , 
    cast(null as TEXT) as 
    
    source_parameter
    
 , 
    cast(null as TEXT) as 
    
    term_parameter
    
 , 
    cast(null as timestamp) as 
    
    updated_at
    
 


        
, 'pardot' || '.'|| 'pardot_integration_tests' as source_relation


    from base
),

final as (

    select
        source_relation,
        id as visitor_id,
        prospect_id,
        created_at as created_timestamp,
        page_view_count,
        _fivetran_synced,
        campaign_parameter as utm_campaign,
        content_parameter as utm_content,
        hostname,
        ip_address,
        medium_parameter as utm_medium,
        source_parameter as utm_source,
        term_parameter as utm_term,
        updated_at as updated_timestamp
    from fields
)

select * from final
