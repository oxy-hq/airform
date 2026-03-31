with source as (
    select * from {{ source('raw', 'raw_users') }}
),

renamed as (
    select
        id as user_id
,        country
,        last_name
,        status
,        first_name
,        updated_at
,        created_at
    from source
)

select * from renamed
