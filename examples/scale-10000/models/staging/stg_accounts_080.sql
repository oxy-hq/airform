with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        account_name
,        plan_type
,        mrr
,        owner_id
    from source
)
select * from renamed
