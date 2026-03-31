with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        last_name
,        account_id
,        status
,        country
    from source
)
select * from renamed
