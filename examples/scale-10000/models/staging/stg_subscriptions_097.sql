with source as (
    select * from {{ source('raw', 'raw_subscriptions') }}
),
renamed as (
    select
        id as subscription_id
,        status
,        auto_renew
,        end_date
,        currency
,        start_date
    from source
)
select * from renamed
