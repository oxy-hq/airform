with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        interval_months
,        auto_renew
,        start_date
,        plan_id
,        currency
    from source
)
select * from renamed
