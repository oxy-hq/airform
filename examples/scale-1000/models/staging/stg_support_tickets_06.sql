with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),

renamed as (
    select
        id as support_ticket_id
,        account_id
,        subject
,        user_id
,        agent_id
,        priority
    from source
)

select * from renamed
