with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        fee
,        method
,        status
,        invoice_id
,        processed_at
    from source
)
select * from renamed
