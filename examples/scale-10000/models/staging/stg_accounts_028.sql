with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        mrr
,        owner_id
,        plan_type
,        status
,        region
,        created_at
,        company_size
    from source
)
select * from renamed
