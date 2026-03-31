with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        category
,        priority
,        user_id
,        resolved_at
,        account_id
,        subject
,        status
    from source
)
select * from renamed
