with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        processed_at
,        net_amount
,        status
,        reference_id
,        fee
,        amount
,        currency
    from source
)
select * from renamed
