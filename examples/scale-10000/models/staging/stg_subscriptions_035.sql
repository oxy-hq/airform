with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        amount
,        start_date
,        plan_id
,        currency
,        status
,        interval_months
    from source
)
select * from renamed
