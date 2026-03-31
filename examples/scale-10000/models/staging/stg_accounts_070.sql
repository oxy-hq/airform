with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        mrr
,        plan_type
,        status
,        owner_id
,        company_size
,        account_name
,        region
    from source
)
select * from renamed
