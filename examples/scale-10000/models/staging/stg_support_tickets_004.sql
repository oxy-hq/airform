with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        category
,        resolved_at
,        account_id
,        subject
,        agent_id
,        created_at
    from source
)
select * from renamed
