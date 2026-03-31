with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        resolved_at
,        account_id
,        category
,        priority
,        created_at
,        subject
,        status
    from source
)
select * from renamed
