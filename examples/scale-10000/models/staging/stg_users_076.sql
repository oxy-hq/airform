with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        email
,        first_name
,        country
    from source
)
select * from renamed
