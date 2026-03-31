with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        status
,        category
,        created_at
,        user_id
,        subject
,        resolved_at
    from source
)
select * from renamed
