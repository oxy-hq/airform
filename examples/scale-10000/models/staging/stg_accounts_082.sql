with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        industry
,        account_name
,        status
,        mrr
    from source
)
select * from renamed
