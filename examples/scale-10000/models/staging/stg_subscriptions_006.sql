with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        plan_id
,        status
,        auto_renew
    from source
)
select * from renamed
