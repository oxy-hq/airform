with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        account_id
,        created_at
,        country
,        status
    from source
)
select * from renamed
