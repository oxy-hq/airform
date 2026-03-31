with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        country
,        updated_at
,        email
,        first_name
    from source
)
select * from renamed
