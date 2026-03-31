with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        region
,        owner_id
,        mrr
,        industry
    from source
)
select * from renamed
