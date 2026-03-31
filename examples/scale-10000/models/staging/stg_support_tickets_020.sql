with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        user_id
,        created_at
,        subject
,        account_id
,        status
,        agent_id
,        resolved_at
    from source
)
select * from renamed
