with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        resolved_at
,        status
,        created_at
,        category
,        agent_id
    from source
)
select * from renamed
