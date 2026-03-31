with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        status
,        account_name
,        region
,        mrr
,        plan_type
,        industry
,        created_at
    from source
)
select * from renamed
