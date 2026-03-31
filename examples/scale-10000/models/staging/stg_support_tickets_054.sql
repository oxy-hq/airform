with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        account_id
,        subject
,        agent_id
,        category
,        priority
,        created_at
,        user_id
    from source
)
select * from renamed
