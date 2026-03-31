with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        subject
,        agent_id
,        status
,        resolved_at
,        account_id
,        user_id
,        created_at
    from source
)
select * from renamed
