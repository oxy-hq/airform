with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        net_amount
,        currency
,        status
,        fee
    from source
)
select * from renamed
