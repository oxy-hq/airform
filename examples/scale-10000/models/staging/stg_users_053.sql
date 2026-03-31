with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        created_at
,        updated_at
,        signup_source
,        last_name
,        country
    from source
)
select * from renamed
