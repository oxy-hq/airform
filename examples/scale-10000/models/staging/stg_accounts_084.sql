with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        mrr
,        created_at
,        industry
,        company_size
,        region
,        status
,        plan_type
    from source
)
select * from renamed
