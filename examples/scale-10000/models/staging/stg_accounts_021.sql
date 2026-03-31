with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        status
,        region
,        created_at
,        plan_type
,        owner_id
,        account_name
,        industry
    from source
)
select * from renamed
