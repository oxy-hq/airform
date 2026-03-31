with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        processed_at
,        net_amount
,        amount
,        reference_id
,        method
,        status
,        invoice_id
    from source
)
select * from renamed
