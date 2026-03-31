with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        signup_source
,        first_name
,        email
    from source
)
select * from renamed
