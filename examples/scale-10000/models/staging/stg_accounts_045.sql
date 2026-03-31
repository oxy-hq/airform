with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        mrr
,        created_at
,        status
,        company_size
,        plan_type
,        owner_id
    from source
)
select * from renamed
