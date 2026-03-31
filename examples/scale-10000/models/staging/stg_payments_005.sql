with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        reference_id
,        invoice_id
    from source
)
select * from renamed
