with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        category
,        account_id
,        user_id
,        agent_id
,        priority
,        status
    from source
)
select * from renamed
