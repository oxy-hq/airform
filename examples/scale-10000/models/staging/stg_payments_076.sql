with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        fee
,        status
,        processed_at
,        amount
,        invoice_id
    from source
)
select * from renamed
