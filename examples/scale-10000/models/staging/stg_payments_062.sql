with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        processed_at
,        reference_id
,        fee
,        net_amount
,        status
,        method
,        currency
    from source
)
select * from renamed
