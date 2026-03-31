with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        account_id
,        priority
,        resolved_at
,        created_at
,        agent_id
,        user_id
,        subject
    from source
)
select * from renamed
