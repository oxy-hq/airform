with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        plan_type
,        status
,        region
,        owner_id
    from source
)
select * from renamed
