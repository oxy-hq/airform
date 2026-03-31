with source as (
    select * from {{ source('raw', 'raw_users') }}
),
renamed as (
    select
        id as user_id
,        account_id
,        status
,        country
,        last_name
    from source
)
select * from renamed
