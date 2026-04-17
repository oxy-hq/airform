with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__brand_tmp"

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
    cast(null as boolean) as 
    
    active
    
 , 
    cast(null as TEXT) as 
    
    brand_url
    
 , 
    cast(null as boolean) as 
    
    has_help_center
    
 , 
    cast(null as TEXT) as 
    
    help_center_state
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as TEXT) as 
    
    logo_content_type
    
 , 
    cast(null as TEXT) as 
    
    logo_content_url
    
 , 
    cast(null as boolean) as 
    
    logo_deleted
    
 , 
    cast(null as TEXT) as 
    
    logo_file_name
    
 , 
    cast(null as integer) as 
    
    logo_height
    
 , 
    cast(null as integer) as 
    
    logo_id
    
 , 
    cast(null as boolean) as 
    
    logo_inline
    
 , 
    cast(null as TEXT) as 
    
    logo_mapped_content_url
    
 , 
    cast(null as integer) as 
    
    logo_size
    
 , 
    cast(null as TEXT) as 
    
    logo_url
    
 , 
    cast(null as integer) as 
    
    logo_width
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as TEXT) as 
    
    subdomain
    
 , 
    cast(null as TEXT) as 
    
    url
    
 



        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation

        
    from base
),

final as (
    
    select 
        id as brand_id,
        brand_url,
        name,
        subdomain,
        active as is_active,
        source_relation
        
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select * 
from final
