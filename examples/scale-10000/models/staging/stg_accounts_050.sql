with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        account_name
,        industry
,        region
,        owner_id
,        plan_type
,        created_at
    from source
)
select * from renamed
