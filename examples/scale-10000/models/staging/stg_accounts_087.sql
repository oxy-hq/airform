with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        owner_id
,        status
,        account_name
,        plan_type
,        created_at
,        industry
    from source
)
select * from renamed
