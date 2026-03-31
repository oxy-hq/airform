with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        priority
,        account_id
,        status
,        subject
,        user_id
,        created_at
,        resolved_at
    from source
)
select * from renamed
