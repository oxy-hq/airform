with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        account_id
,        created_at
,        last_name
    from source
)
select * from renamed
