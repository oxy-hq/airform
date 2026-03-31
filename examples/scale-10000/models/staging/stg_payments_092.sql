with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        invoice_id
,        processed_at
,        status
,        currency
,        net_amount
,        reference_id
    from source
)
select * from renamed
