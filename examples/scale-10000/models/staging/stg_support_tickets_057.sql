with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        user_id
,        status
,        resolved_at
,        category
,        subject
,        priority
    from source
)
select * from renamed
