with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),

renamed as (
    select
        id as account_id
,        owner_id
,        status
,        plan_type
,        mrr
    from source
)

select * from renamed
