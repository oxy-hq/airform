with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        plan_type
,        owner_id
,        company_size
,        region
,        status
,        created_at
    from source
)
select * from renamed
