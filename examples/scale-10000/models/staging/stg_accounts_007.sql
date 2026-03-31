with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        status
,        region
,        plan_type
,        mrr
,        created_at
,        industry
    from source
)
select * from renamed
