with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        user_id
,        account_id
,        priority
,        created_at
,        subject
,        agent_id
    from source
)
select * from renamed
