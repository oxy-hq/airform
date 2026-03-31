with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        interval_months
,        end_date
,        amount
,        start_date
    from source
)
select * from renamed
