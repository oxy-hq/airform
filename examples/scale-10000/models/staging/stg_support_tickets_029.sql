with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        agent_id
,        user_id
,        subject
,        priority
    from source
)
select * from renamed
