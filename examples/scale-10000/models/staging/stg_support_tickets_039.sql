with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        agent_id
,        user_id
,        created_at
,        subject
    from source
)
select * from renamed
