with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        agent_id
,        account_id
,        priority
,        created_at
,        status
,        subject
    from source
)
select * from renamed
