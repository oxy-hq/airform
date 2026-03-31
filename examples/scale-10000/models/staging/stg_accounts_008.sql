with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        account_name
,        owner_id
,        mrr
,        company_size
,        plan_type
    from source
)
select * from renamed
