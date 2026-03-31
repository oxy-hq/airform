with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        region
,        mrr
,        plan_type
,        account_name
,        status
    from source
)
select * from renamed
