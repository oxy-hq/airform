with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),

renamed as (
    select
        id as support_ticket_id
,        status
,        category
,        subject
    from source
)

select * from renamed
