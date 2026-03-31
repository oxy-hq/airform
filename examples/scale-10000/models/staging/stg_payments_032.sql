with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        net_amount
,        amount
,        fee
,        processed_at
,        currency
,        reference_id
    from source
)
select * from renamed
