with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        industry
,        region
,        status
,        mrr
,        plan_type
    from source
)
select * from renamed
