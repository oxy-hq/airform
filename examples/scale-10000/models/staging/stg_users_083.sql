with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        created_at
,        signup_source
    from source
)
select * from renamed
