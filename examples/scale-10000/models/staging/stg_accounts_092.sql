with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        plan_type
,        status
,        industry
,        mrr
,        company_size
,        created_at
    from source
)
select * from renamed
