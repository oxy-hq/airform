with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        priority
,        agent_id
,        subject
,        category
,        status
,        account_id
    from source
)
select * from renamed
