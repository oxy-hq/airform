with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        status
,        created_at
,        user_id
,        agent_id
,        category
    from source
)
select * from renamed
