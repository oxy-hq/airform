with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        resolved_at
,        account_id
,        user_id
,        priority
,        subject
,        created_at
,        agent_id
    from source
)
select * from renamed
