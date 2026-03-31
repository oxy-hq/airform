with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        status
,        resolved_at
,        subject
,        priority
,        agent_id
,        created_at
,        account_id
    from source
)
select * from renamed
