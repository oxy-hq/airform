with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        status
,        subject
,        resolved_at
,        priority
,        user_id
,        agent_id
,        account_id
    from source
)
select * from renamed
