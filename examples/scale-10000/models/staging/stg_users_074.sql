with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        created_at
,        account_id
,        country
,        updated_at
,        first_name
,        status
    from source
)
select * from renamed
