with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        reference_id
,        processed_at
,        currency
,        net_amount
,        invoice_id
,        amount
,        method
    from source
)
select * from renamed
