with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        created_at
,        resolved_at
,        subject
,        user_id
,        category
,        status
    from source
)
select * from renamed
