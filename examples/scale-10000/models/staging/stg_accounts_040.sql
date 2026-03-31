with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        created_at
,        mrr
,        region
,        owner_id
,        account_name
    from source
)
select * from renamed
