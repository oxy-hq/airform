with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        resolved_at
,        user_id
,        account_id
,        category
,        created_at
,        status
    from source
)
select * from renamed
