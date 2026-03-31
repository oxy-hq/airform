with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        signup_source
,        country
,        email
,        created_at
,        first_name
    from source
)
select * from renamed
