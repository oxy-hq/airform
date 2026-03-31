with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        end_date
,        start_date
,        account_id
,        plan_id
,        amount
    from source
)
select * from renamed
