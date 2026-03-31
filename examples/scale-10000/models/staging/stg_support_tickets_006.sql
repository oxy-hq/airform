with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        category
,        priority
,        status
,        agent_id
,        created_at
,        subject
,        user_id
    from source
)
select * from renamed
