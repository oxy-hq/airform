with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        status
,        account_id
,        user_id
,        priority
,        created_at
,        category
,        agent_id
    from source
)
select * from renamed
