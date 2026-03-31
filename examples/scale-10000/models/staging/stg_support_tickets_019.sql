with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        resolved_at
,        created_at
,        priority
    from source
)
select * from renamed
