with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        subject
,        user_id
,        account_id
,        status
,        agent_id
    from source
)
select * from renamed
