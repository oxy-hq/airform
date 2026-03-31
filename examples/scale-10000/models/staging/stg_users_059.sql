with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        first_name
,        updated_at
,        signup_source
,        email
,        created_at
    from source
)
select * from renamed
