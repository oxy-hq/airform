with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        reference_id
,        fee
,        status
,        method
,        processed_at
,        amount
    from source
)
select * from renamed
