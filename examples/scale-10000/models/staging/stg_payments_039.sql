with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        reference_id
,        fee
,        method
,        net_amount
    from source
)
select * from renamed
