with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        company_size
,        account_name
,        plan_type
,        status
,        mrr
    from source
)
select * from renamed
