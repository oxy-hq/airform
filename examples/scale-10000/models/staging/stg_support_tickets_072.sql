with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        agent_id
,        account_id
,        priority
,        resolved_at
,        user_id
,        status
,        created_at
    from source
)
select * from renamed
