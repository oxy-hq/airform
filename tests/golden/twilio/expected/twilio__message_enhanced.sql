with messages as (

    select *
    from "twilio"."main_twilio"."int_twilio__messages"
),


messaging_service as (

    select *
    from "twilio"."main_twilio_source"."stg_twilio__messaging_service"
),



final as (

    select
        messages.source_relation,
        messages.message_id,
        messages.messaging_service_id,
        messages.timestamp_sent,
        messages.date_day,
        messages.date_week,
        messages.date_month,
        messages.account_id,
        messages.created_at,
        messages.direction,
        messages.phone_number,
        messages.body,
        messages.num_characters,
        (messages.num_characters- 

    length(
        body_no_spaces
    )) + 1 as num_words,
        messages.status,
        messages.error_code,
        messages.error_message,
        messages.num_media,
        messages.num_segments,
        messages.price,
        messages.price_unit,
        messages.updated_at

        
        ,
        messaging_service.friendly_name,
        messaging_service.inbound_method,
        messaging_service.us_app_to_person_registered,
        messaging_service.use_inbound_webhook_on_number,
        messaging_service.use_case

        

    from messages


    
    left join messaging_service
        on messages.messaging_service_id = messaging_service.messaging_service_id
        and messages.source_relation = messaging_service.source_relation

    

)

select *
from final
