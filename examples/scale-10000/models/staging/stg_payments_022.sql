with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        processed_at
,        method
,        reference_id
,        fee
,        net_amount
,        currency
,        amount
    from source
)
select * from renamed
