with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),

renamed as (
    select
        id as support_ticket_id
,        account_id
,        created_at
,        resolved_at
,        priority
,        user_id
,        subject
,        agent_id
    from source
)

select * from renamed
