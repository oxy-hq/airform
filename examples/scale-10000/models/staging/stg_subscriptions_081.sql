with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        status
,        currency
,        plan_id
,        auto_renew
    from source
)
select * from renamed
