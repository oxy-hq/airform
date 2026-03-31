with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        agent_id
,        priority
,        resolved_at
,        subject
,        account_id
,        user_id
,        category
    from source
)
select * from renamed
