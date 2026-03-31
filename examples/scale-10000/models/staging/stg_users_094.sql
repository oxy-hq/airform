with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        updated_at
,        status
,        country
,        first_name
,        last_name
,        signup_source
    from source
)
select * from renamed
