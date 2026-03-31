with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        subject
,        category
,        agent_id
,        priority
,        created_at
,        user_id
,        account_id
    from source
)
select * from renamed
