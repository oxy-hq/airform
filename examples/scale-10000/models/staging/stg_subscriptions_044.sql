with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        start_date
,        currency
,        interval_months
,        amount
    from source
)
select * from renamed
