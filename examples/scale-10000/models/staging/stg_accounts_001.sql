with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        plan_type
,        created_at
,        status
,        industry
,        mrr
    from source
)
select * from renamed
