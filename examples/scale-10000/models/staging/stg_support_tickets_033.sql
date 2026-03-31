with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        agent_id
,        category
,        priority
,        subject
,        status
,        account_id
,        resolved_at
    from source
)
select * from renamed
