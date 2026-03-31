with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),

renamed as (
    select
        id as subscription_id
,        auto_renew
,        end_date
,        status
,        currency
,        plan_id
,        amount
,        interval_months
    from source
)

select * from renamed
