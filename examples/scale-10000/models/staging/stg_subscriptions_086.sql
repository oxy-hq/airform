with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        plan_id
,        end_date
,        interval_months
,        auto_renew
,        currency
,        status
,        start_date
    from source
)
select * from renamed
