with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        fee
,        reference_id
,        status
,        currency
,        net_amount
    from source
)
select * from renamed
