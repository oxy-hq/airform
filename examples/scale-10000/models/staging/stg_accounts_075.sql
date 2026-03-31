with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        mrr
,        region
,        plan_type
,        status
,        owner_id
    from source
)
select * from renamed
