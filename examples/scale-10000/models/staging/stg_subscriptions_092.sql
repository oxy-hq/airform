with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        interval_months
,        start_date
,        currency
,        end_date
,        status
,        auto_renew
,        plan_id
    from source
)
select * from renamed
