with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        created_at
,        status
,        account_id
,        agent_id
    from source
)
select * from renamed
