with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        category
,        resolved_at
,        agent_id
,        priority
    from source
)
select * from renamed
