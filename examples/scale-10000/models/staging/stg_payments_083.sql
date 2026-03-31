with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        status
,        reference_id
,        fee
,        method
,        net_amount
,        currency
    from source
)
select * from renamed
