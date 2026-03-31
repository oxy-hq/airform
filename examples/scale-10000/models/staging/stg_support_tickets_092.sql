with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        status
,        category
,        account_id
,        agent_id
,        priority
,        subject
,        resolved_at
    from source
)
select * from renamed
