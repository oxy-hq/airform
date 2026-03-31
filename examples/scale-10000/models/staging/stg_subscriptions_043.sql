with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        plan_id
,        start_date
,        auto_renew
,        amount
    from source
)
select * from renamed
