with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        method
,        net_amount
,        status
,        amount
,        fee
    from source
)
select * from renamed
