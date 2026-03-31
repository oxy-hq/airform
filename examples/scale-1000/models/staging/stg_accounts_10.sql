with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),

renamed as (
    select
        id as account_id
,        owner_id
,        plan_type
,        region
,        industry
,        created_at
,        account_name
,        company_size
    from source
)

select * from renamed
