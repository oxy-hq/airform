with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        updated_at
,        first_name
,        last_name
,        created_at
,        country
,        account_id
    from source
)
select * from renamed
