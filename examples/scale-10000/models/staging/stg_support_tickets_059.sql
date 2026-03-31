with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        account_id
,        status
,        priority
,        agent_id
,        resolved_at
,        created_at
    from source
)
select * from renamed
