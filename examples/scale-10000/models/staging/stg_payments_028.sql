with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        fee
,        net_amount
,        processed_at
,        amount
,        reference_id
,        method
    from source
)
select * from renamed
