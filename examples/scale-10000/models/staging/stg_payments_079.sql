with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        invoice_id
,        processed_at
,        amount
,        status
,        net_amount
,        reference_id
    from source
)
select * from renamed
