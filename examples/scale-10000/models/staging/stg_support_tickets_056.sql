with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        category
,        subject
,        account_id
,        resolved_at
,        priority
,        agent_id
,        status
    from source
)
select * from renamed
