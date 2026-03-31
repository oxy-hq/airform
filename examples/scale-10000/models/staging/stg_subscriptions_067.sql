with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        currency
,        amount
,        plan_id
,        end_date
,        account_id
    from source
)
select * from renamed
