with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        auto_renew
,        currency
,        plan_id
    from source
)
select * from renamed
