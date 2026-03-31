with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        email
,        account_id
    from source
)
select * from renamed
