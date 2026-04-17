with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__user_tmp"

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
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as boolean) as 
    
    active
    
 , 
    cast(null as TEXT) as 
    
    alias
    
 , 
    cast(null as integer) as 
    
    authenticity_token
    
 , 
    cast(null as boolean) as 
    
    chat_only
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as integer) as 
    
    details
    
 , 
    cast(null as TEXT) as 
    
    email
    
 , 
    cast(null as integer) as 
    
    external_id
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as timestamp) as 
    
    last_login_at
    
 , 
    cast(null as TEXT) as 
    
    locale
    
 , 
    cast(null as integer) as 
    
    locale_id
    
 , 
    cast(null as boolean) as 
    
    moderator
    
 , 
    cast(null as TEXT) as 
    
    name
    
 , 
    cast(null as integer) as 
    
    notes
    
 , 
    cast(null as boolean) as 
    
    only_private_comments
    
 , 
    cast(null as integer) as 
    
    organization_id
    
 , 
    cast(null as TEXT) as 
    
    phone
    
 , 
    cast(null as integer) as 
    
    remote_photo_url
    
 , 
    cast(null as boolean) as 
    
    restricted_agent
    
 , 
    cast(null as TEXT) as 
    
    role
    
 , 
    cast(null as boolean) as 
    
    shared
    
 , 
    cast(null as boolean) as 
    
    shared_agent
    
 , 
    cast(null as integer) as 
    
    signature
    
 , 
    cast(null as boolean) as 
    
    suspended
    
 , 
    cast(null as TEXT) as 
    
    ticket_restriction
    
 , 
    cast(null as TEXT) as 
    
    time_zone
    
 , 
    cast(null as boolean) as 
    
    two_factor_auth_enabled
    
 , 
    cast(null as TEXT) as 
    
    updated_at
    
 , 
    cast(null as TEXT) as 
    
    url
    
 , 
    cast(null as boolean) as 
    
    verified
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as ( 
    
    select 
        id as user_id,
        external_id,
        _fivetran_synced,
        _fivetran_deleted,
        cast(last_login_at as timestamp) as last_login_at,
        cast(created_at as timestamp) as created_at,
        cast(updated_at as timestamp) as updated_at,
        email,
        name,
        organization_id,
        phone,
        role,
        ticket_restriction,
        time_zone,
        locale,
        active as is_active,
        suspended as is_suspended,
        source_relation

        




        
    from fields
)

select * 
from final
