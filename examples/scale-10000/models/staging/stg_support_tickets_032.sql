with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        created_at
,        resolved_at
,        status
,        subject
,        agent_id
,        priority
,        category
    from source
)
select * from renamed
