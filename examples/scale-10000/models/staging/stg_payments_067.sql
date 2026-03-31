with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        fee
,        currency
,        reference_id
,        processed_at
,        net_amount
,        invoice_id
,        status
    from source
)
select * from renamed
