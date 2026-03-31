with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        last_name
,        country
,        first_name
,        updated_at
    from source
)
select * from renamed
