with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        company_size
,        owner_id
,        region
,        account_name
,        status
,        created_at
,        plan_type
    from source
)
select * from renamed
