with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        priority
,        account_id
,        status
,        user_id
,        agent_id
,        category
    from source
)
select * from renamed
