with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        status
,        updated_at
,        last_name
,        signup_source
    from source
)
select * from renamed
