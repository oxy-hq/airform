with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        reference_id
,        amount
,        fee
,        processed_at
,        net_amount
,        invoice_id
    from source
)
select * from renamed
