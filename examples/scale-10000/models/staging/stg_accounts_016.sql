with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        owner_id
,        plan_type
,        region
,        mrr
,        industry
,        created_at
    from source
)
select * from renamed
