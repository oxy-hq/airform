with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        salary
,        last_name
,        email
,        status
    from source
)
select * from renamed
