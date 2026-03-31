with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        account_id
,        created_at
,        user_id
,        priority
,        resolved_at
,        agent_id
    from source
)
select * from renamed
