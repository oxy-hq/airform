with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        created_at
,        subject
,        priority
,        agent_id
,        user_id
,        account_id
    from source
)
select * from renamed
