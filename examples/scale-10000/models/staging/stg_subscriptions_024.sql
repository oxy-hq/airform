with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        auto_renew
,        plan_id
    from source
)
select * from renamed
