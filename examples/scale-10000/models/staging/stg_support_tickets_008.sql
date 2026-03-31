with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        subject
,        user_id
,        priority
,        category
,        created_at
,        resolved_at
,        agent_id
    from source
)
select * from renamed
