with source as (
    select * from {{ source('raw', 'raw_payments') }}
),
renamed as (
    select
        id as payment_id
,        status
,        processed_at
,        reference_id
,        net_amount
,        method
    from source
)
select * from renamed
