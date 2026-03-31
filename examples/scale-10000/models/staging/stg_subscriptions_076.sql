with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        plan_id
,        auto_renew
,        end_date
,        status
,        currency
    from source
)
select * from renamed
