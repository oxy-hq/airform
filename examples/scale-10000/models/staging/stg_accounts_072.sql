with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        account_name
,        status
,        company_size
,        industry
,        plan_type
,        created_at
,        owner_id
    from source
)
select * from renamed
