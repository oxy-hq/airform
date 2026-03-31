with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        plan_type
,        owner_id
,        account_name
,        company_size
,        mrr
    from source
)
select * from renamed
