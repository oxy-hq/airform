with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        amount
,        processed_at
,        fee
,        reference_id
    from source
)
select * from renamed
