with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        last_name
,        status
,        email
,        created_at
,        account_id
,        first_name
    from source
)
select * from renamed
