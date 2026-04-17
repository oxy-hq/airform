with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_tmp"

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
    
    allow_channelback
    
 , 
    cast(null as integer) as 
    
    assignee_id
    
 , 
    cast(null as integer) as 
    
    brand_id
    
 , 
    cast(null as timestamp) as 
    
    created_at
    
 , 
    cast(null as TEXT) as 
    
    description
    
 , 
    cast(null as timestamp) as 
    
    due_at
    
 , 
    cast(null as integer) as 
    
    external_id
    
 , 
    cast(null as integer) as 
    
    forum_topic_id
    
 , 
    cast(null as integer) as 
    
    group_id
    
 , 
    cast(null as boolean) as 
    
    has_incidents
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as boolean) as 
    
    is_public
    
 , 
    cast(null as TEXT) as 
    
    merged_ticket_ids
    
 , 
    cast(null as integer) as 
    
    organization_id
    
 , 
    cast(null as TEXT) as 
    
    priority
    
 , 
    cast(null as integer) as 
    
    problem_id
    
 , 
    cast(null as integer) as 
    
    recipient
    
 , 
    cast(null as integer) as 
    
    requester_id
    
 , 
    cast(null as TEXT) as 
    
    status
    
 , 
    cast(null as TEXT) as 
    
    subject
    
 , 
    cast(null as integer) as 
    
    submitter_id
    
 , 
    cast(null as integer) as 
    
    system_ccs
    
 , 
    cast(null as TEXT) as 
    
    system_client
    
 , 
    cast(null as TEXT) as 
    
    system_ip_address
    
 , 
    cast(null as integer) as 
    
    system_json_email_identifier
    
 , 
    cast(null as float) as 
    
    system_latitude
    
 , 
    cast(null as TEXT) as 
    
    system_location
    
 , 
    cast(null as float) as 
    
    system_longitude
    
 , 
    cast(null as integer) as 
    
    system_machine_generated
    
 , 
    cast(null as integer) as 
    
    system_message_id
    
 , 
    cast(null as integer) as 
    
    system_raw_email_identifier
    
 , 
    cast(null as integer) as 
    
    ticket_form_id
    
 , 
    cast(null as TEXT) as 
    
    type
    
 , 
    cast(null as TEXT) as 
    
    updated_at
    
 , 
    cast(null as TEXT) as 
    
    url
    
 , 
    cast(null as TEXT) as 
    
    via_channel
    
 , 
    cast(null as integer) as 
    
    via_source_from_address
    
 , 
    cast(null as integer) as 
    
    via_source_from_id
    
 , 
    cast(null as integer) as 
    
    via_source_from_title
    
 , 
    cast(null as integer) as 
    
    via_source_rel
    
 , 
    cast(null as integer) as 
    
    via_source_to_address
    
 , 
    cast(null as integer) as 
    
    via_source_to_name
    
 



        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation

        
    from base
),

final as (
    
    select 
        id as ticket_id,
        _fivetran_synced,
        _fivetran_deleted,
        assignee_id,
        brand_id,
        cast(created_at as timestamp) as created_at,
        cast(updated_at as timestamp) as updated_at,
        description,
        due_at,
        group_id,
        external_id,
        is_public,
        organization_id,
        priority,
        recipient,
        requester_id,
        status,
        subject,
        problem_id,
        submitter_id,
        ticket_form_id,
        type,
        url,
        via_channel as created_channel,
        via_source_from_id as source_from_id,
        via_source_from_title as source_from_title,
        via_source_rel as source_rel,
        via_source_to_address as source_to_address,
        via_source_to_name as source_to_name,
        source_relation

        





    from fields
)

select * 
from final
