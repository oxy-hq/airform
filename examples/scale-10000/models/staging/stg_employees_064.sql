with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        salary
,        title
,        email
,        last_name
    from source
)
select * from renamed
