with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        plan_id
,        amount
,        account_id
,        currency
    from source
)
select * from renamed
