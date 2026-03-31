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
,        account_id
,        category
    from source
)
select * from renamed
