with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        status
,        fee
,        invoice_id
,        reference_id
,        amount
,        processed_at
    from source
)
select * from renamed
