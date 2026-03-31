with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        plan_type
,        account_name
,        owner_id
,        mrr
,        created_at
    from source
)
select * from renamed
