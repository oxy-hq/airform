with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        subject
,        category
,        resolved_at
,        status
,        created_at
    from source
)
select * from renamed
