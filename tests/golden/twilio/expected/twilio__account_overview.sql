with messages as (

    select *
    from "twilio"."main_twilio"."int_twilio__messages"
),

account_history as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__account_history"
)


,
usage_record as (

    select * 
    from "twilio"."main_twilio_source"."stg_twilio__usage_record"
)


select
    messages.source_relation,
    messages.account_id,
    account_history.friendly_name as account_name,
    account_history.status as account_status,
    account_history.type as account_type,
    messages.date_day,
    messages.date_week,
    messages.date_month,
    messages.price_unit,
    count(case
        when messages.direction like '%outbound%'
        then messages.message_id end)
        as total_outbound_messages,
    count(case
        when messages.direction like '%inbound%'
        then messages.message_id end)
        as total_inbound_messages,

    
    count(case
        when messages.status like 'accepted'
        then messages.message_id end)
        as total_accepted_messages,
    
    count(case
        when messages.status like 'scheduled'
        then messages.message_id end)
        as total_scheduled_messages,
    
    count(case
        when messages.status like 'canceled'
        then messages.message_id end)
        as total_canceled_messages,
    
    count(case
        when messages.status like 'queued'
        then messages.message_id end)
        as total_queued_messages,
    
    count(case
        when messages.status like 'sending'
        then messages.message_id end)
        as total_sending_messages,
    
    count(case
        when messages.status like 'sent'
        then messages.message_id end)
        as total_sent_messages,
    
    count(case
        when messages.status like 'failed'
        then messages.message_id end)
        as total_failed_messages,
    
    count(case
        when messages.status like 'delivered'
        then messages.message_id end)
        as total_delivered_messages,
    
    count(case
        when messages.status like 'undelivered'
        then messages.message_id end)
        as total_undelivered_messages,
    
    count(case
        when messages.status like 'receiving'
        then messages.message_id end)
        as total_receiving_messages,
    
    count(case
        when messages.status like 'received'
        then messages.message_id end)
        as total_received_messages,
    
    count(case
        when messages.status like 'read'
        then messages.message_id end)
        as total_read_messages,
    
    
    count(messages.message_id) as total_messages,
    round( cast(sum(messages.price) as numeric(28,6)), 2) * -1 as total_messages_spend
    
    
    , round( cast(sum(usage_record.price) as numeric(28,6)), 2) as total_account_spend
    

from messages

left join usage_record
    on messages.account_id = usage_record.account_id
    and messages.source_relation = usage_record.source_relation
    and messages.date_day = usage_record.start_date

left join account_history
    on messages.account_id = account_history.account_id
    and messages.source_relation = account_history.source_relation

group by 1,2,3,4,5,6,7,8,9
