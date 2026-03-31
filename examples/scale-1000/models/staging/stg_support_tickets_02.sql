with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),

renamed as (
    select
        id as support_ticket_id
,        resolved_at
,        account_id
,        agent_id
,        status
,        subject
,        category
,        created_at
    from source
)

select * from renamed
