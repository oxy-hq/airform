with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        first_name
,        status
,        signup_source
,        country
,        last_name
    from source
)
select * from renamed
