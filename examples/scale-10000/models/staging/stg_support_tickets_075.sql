with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        status
,        user_id
,        created_at
,        category
    from source
)
select * from renamed
