with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        resolved_at
,        created_at
,        user_id
,        subject
,        category
    from source
)
select * from renamed
