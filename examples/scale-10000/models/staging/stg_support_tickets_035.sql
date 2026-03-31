with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        user_id
,        subject
,        category
,        resolved_at
,        priority
    from source
)
select * from renamed
