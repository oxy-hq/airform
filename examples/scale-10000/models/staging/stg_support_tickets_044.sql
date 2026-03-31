with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        category
,        created_at
,        agent_id
,        user_id
,        priority
,        resolved_at
,        status
    from source
)
select * from renamed
