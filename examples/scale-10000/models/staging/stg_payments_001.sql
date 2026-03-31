with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        reference_id
,        net_amount
,        processed_at
,        currency
,        invoice_id
,        method
    from source
)
select * from renamed
