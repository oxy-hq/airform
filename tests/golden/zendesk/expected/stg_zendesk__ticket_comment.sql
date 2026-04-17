with base as (

    select * 
    from "zendesk"."main_zendesk_source"."stg_zendesk__ticket_comment_tmp"

),

fields as (

    select
        /*
        The below macro is used to generate the correct SQL for package staging models. It takes a list of columns 
        that are expected/needed (staging_columns from dbt_zendesk/models/tmp/) and compares it with columns 
        in the source (source_columns from dbt_zendesk/macros/).
        For more information refer to our dbt_fivetran_utils documentation (https://github.com/fivetran/dbt_fivetran_utils.git).
        */
        
    cast(null as TEXT) as 
    
    _fivetran_synced
    
 , 
    cast(null as boolean) as 
    
    _fivetran_deleted
    
 , 
    cast(null as TEXT) as 
    
    body
    
 , 
    cast(null as integer) as 
    
    call_duration
    
 , 
    cast(null as integer) as 
    
    call_id
    
 , 
    cast(null as timestamp) as 
    
    created
    
 , 
    cast(null as boolean) as 
    
    facebook_comment
    
 , 
    cast(null as integer) as 
    
    id
    
 , 
    cast(null as integer) as 
    
    location
    
 , 
    cast(null as boolean) as 
    
    public
    
 , 
    cast(null as integer) as 
    
    recording_url
    
 , 
    cast(null as timestamp) as 
    
    started_at
    
 , 
    cast(null as integer) as 
    
    ticket_id
    
 , 
    cast(null as integer) as 
    
    transcription_status
    
 , 
    cast(null as integer) as 
    
    transcription_text
    
 , 
    cast(null as integer) as 
    
    trusted
    
 , 
    cast(null as boolean) as 
    
    tweet
    
 , 
    cast(null as integer) as 
    
    user_id
    
 , 
    cast(null as boolean) as 
    
    voice_comment
    
 , 
    cast(null as integer) as 
    
    voice_comment_transcription_visible
    
 


        
        
, 'zendesk' || '.'|| 'zendesk_integration_tests_63' as source_relation


    from base
),

final as (
    
    select 
        id as ticket_comment_id,
        _fivetran_synced,
        _fivetran_deleted,
        body,
        cast(created as timestamp) as created_at,
        public as is_public,
        ticket_id,
        user_id,
        facebook_comment as is_facebook_comment,
        tweet as is_tweet,
        voice_comment as is_voice_comment,
        source_relation
        
    from fields
)

select * 
from final
