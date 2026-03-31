with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        first_name
,        email
,        country
,        last_name
,        signup_source
,        updated_at
    from source
)
select * from renamed
