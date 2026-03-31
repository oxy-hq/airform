with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        status
,        company_size
,        created_at
,        plan_type
    from source
)
select * from renamed
