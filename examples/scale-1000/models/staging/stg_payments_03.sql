with source as (
    select * from {{ source('raw', 'raw_payments') }}
),

renamed as (
    select
        id as payment_id
,        fee
,        method
,        net_amount
,        status
,        amount
,        currency
    from source
)

select * from renamed
