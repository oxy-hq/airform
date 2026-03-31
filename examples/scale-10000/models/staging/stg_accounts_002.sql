with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        industry
,        owner_id
,        created_at
,        plan_type
,        region
,        status
    from source
)
select * from renamed
