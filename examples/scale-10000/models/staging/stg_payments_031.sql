with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        currency
,        invoice_id
,        reference_id
,        amount
,        processed_at
,        fee
    from source
)
select * from renamed
