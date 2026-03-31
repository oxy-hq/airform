with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        start_date
,        plan_id
,        currency
,        amount
,        auto_renew
    from source
)
select * from renamed
