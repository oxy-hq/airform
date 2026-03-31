with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        mrr
,        plan_type
,        industry
,        account_name
    from source
)
select * from renamed
