with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        mrr
,        region
,        created_at
,        account_name
,        company_size
,        status
,        plan_type
    from source
)
select * from renamed
