with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        reference_id
,        net_amount
,        currency
,        amount
,        method
    from source
)
select * from renamed
