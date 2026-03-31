with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        account_name
,        region
,        mrr
,        plan_type
,        company_size
,        created_at
,        industry
    from source
)
select * from renamed
