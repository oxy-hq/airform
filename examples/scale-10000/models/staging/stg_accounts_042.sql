with source as (
    select * from {{ source('raw', 'raw_accounts') }}
),
renamed as (
    select
        id as account_id
,        company_size
,        plan_type
,        industry
,        status
    from source
)
select * from renamed
