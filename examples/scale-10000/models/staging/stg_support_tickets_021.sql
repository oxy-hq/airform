with source as (
    select * from {{ source('raw', 'raw_support_tickets') }}
),
renamed as (
    select
        id as support_ticket_id
,        subject
,        created_at
,        account_id
,        status
    from source
)
select * from renamed
