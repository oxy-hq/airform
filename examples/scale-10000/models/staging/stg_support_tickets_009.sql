with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        user_id
,        resolved_at
,        status
,        priority
,        created_at
,        agent_id
,        account_id
    from source
)
select * from renamed
