with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        status
,        created_at
,        owner_id
,        region
,        industry
,        company_size
,        plan_type
    from source
)
select * from renamed
