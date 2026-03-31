with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        first_name
,        created_at
,        signup_source
,        country
,        email
,        last_name
    from source
)
select * from renamed
