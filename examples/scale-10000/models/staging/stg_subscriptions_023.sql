with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        account_id
,        start_date
,        status
,        end_date
,        amount
,        currency
    from source
)
select * from renamed
