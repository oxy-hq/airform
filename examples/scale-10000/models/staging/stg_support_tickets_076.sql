with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        subject
,        agent_id
,        created_at
,        account_id
    from source
)
select * from renamed
