with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        method
,        reference_id
,        amount
,        net_amount
,        currency
,        processed_at
    from source
)
select * from renamed
