with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        status
,        owner_id
,        account_name
,        plan_type
,        mrr
,        company_size
    from source
)
select * from renamed
