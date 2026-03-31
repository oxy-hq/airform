with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        plan_id
,        currency
,        auto_renew
,        amount
,        interval_months
,        start_date
    from source
)
select * from renamed
