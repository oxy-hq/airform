with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),

renamed as (
    select
        id as support_ticket_id
,        agent_id
,        resolved_at
,        user_id
,        category
,        created_at
,        subject
    from source
)

select * from renamed
