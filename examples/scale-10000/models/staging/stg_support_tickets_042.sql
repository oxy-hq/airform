with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        subject
,        user_id
,        created_at
,        status
,        resolved_at
    from source
)
select * from renamed
