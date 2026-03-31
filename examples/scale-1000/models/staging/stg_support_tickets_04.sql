with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),

renamed as (
    select
        id as support_ticket_id
,        subject
,        resolved_at
,        agent_id
,        category
,        user_id
,        status
    from source
)

select * from renamed
