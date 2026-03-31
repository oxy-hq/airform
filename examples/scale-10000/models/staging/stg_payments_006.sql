with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        processed_at
,        amount
,        reference_id
,        net_amount
    from source
)
select * from renamed
