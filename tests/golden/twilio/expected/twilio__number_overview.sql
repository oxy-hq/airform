with messages as (

    select *
    from "twilio"."main_twilio"."int_twilio__messages"
)

select
    source_relation,
    phone_number,
    count(case
        when direction like '%outbound%'
        then message_id end)
        as total_outbound_messages,
    count(case
        when direction like '%inbound%'
        then message_id end)
        as total_inbound_messages,

    
    count(case
        when status like 'accepted'
        then message_id end)
        as total_accepted_messages,
    
    count(case
        when status like 'scheduled'
        then message_id end)
        as total_scheduled_messages,
    
    count(case
        when status like 'canceled'
        then message_id end)
        as total_canceled_messages,
    
    count(case
        when status like 'queued'
        then message_id end)
        as total_queued_messages,
    
    count(case
        when status like 'sending'
        then message_id end)
        as total_sending_messages,
    
    count(case
        when status like 'sent'
        then message_id end)
        as total_sent_messages,
    
    count(case
        when status like 'failed'
        then message_id end)
        as total_failed_messages,
    
    count(case
        when status like 'delivered'
        then message_id end)
        as total_delivered_messages,
    
    count(case
        when status like 'undelivered'
        then message_id end)
        as total_undelivered_messages,
    
    count(case
        when status like 'receiving'
        then message_id end)
        as total_receiving_messages,
    
    count(case
        when status like 'received'
        then message_id end)
        as total_received_messages,
    
    count(case
        when status like 'read'
        then message_id end)
        as total_read_messages,
    

    count(message_id) as total_messages,
    sum(price) as total_spend

from messages
group by 1, 2
