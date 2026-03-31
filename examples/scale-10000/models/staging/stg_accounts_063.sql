with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        owner_id
,        status
,        mrr
,        industry
    from source
)
select * from renamed
