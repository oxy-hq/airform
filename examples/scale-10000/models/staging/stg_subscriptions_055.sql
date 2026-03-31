with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        plan_id
,        account_id
,        start_date
,        interval_months
,        currency
,        status
    from source
)
select * from renamed
