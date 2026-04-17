with base as (

    select * 
    from "pardot"."main_stg_pardot"."stg_pardot__visitor_activity_tmp"

),

fields as (

    select
        
    cast(null as timestamp) as 
    
    _fivetran_synced
    
 , 
    cast(null as integer) as 
    
    campaign_id
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    custom_redirect_id
    
 , 
    cast(null as TEXT) as 
    
    details
    
 , 
    cast(null as integer) as 
    
    email_id
    
 , 
    cast(null as integer) as 
    
    email_template_id
    
 , 
    cast(null as integer) as 
    
    file_id
    
 , 
    cast(null as integer) as 
    
    form_handler_id
    
 , 
    cast(null as integer) as 
    
    form_id
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    landing_page_id
    
 , 
    cast(null as integer) as 
    
    list_email_id
    
 , 
    cast(null as integer) as 
    
    multivariate_test_variation_id
    
 , 
    cast(null as TEXT) as 
    
    opportunity_id
    
 , 
    cast(null as integer) as 
    
    paid_search_ad_id
    
 , 
    cast(null as integer) as 
    
    prospect_id
    
 , 
    cast(null as integer) as 
    
    site_search_query_id
    
 , 
    cast(null as integer) as 
    
    type
    
 , 
    cast(null as TEXT) as 
    
    type_name
    
 , 
    cast(null as TEXT) as 
    
    visit_id
    
 , 
    cast(null as integer) as 
    
    visitor_id
    
 , 
    cast(null as integer) as 
    
    visitor_page_view_id
    
 


        
, 'pardot' || '.'|| 'pardot_integration_tests' as source_relation


    from base
),

final as (

    select
        source_relation,
        id as visitor_activity_id,
        type_name as event_type_name,
        prospect_id,
        visitor_id,
        created_at as created_timestamp,
        campaign_id,
        opportunity_id,
        _fivetran_synced,
        email_id
    from fields
)

select * from final
