with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        start_date
,        account_id
,        interval_months
,        auto_renew
,        plan_id
,        status
    from source
)
select * from renamed
