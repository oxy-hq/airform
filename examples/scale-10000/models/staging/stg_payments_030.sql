with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        status
,        processed_at
,        amount
,        reference_id
,        net_amount
,        invoice_id
    from source
)
select * from renamed
