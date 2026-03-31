with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        email
,        country
,        status
,        last_name
    from source
)
select * from renamed
