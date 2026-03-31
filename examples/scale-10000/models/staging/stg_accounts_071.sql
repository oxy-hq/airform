with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        region
,        industry
,        owner_id
,        plan_type
,        created_at
,        account_name
    from source
)
select * from renamed
