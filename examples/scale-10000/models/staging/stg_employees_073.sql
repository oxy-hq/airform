with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        salary
,        first_name
,        hire_date
,        last_name
,        email
    from source
)
select * from renamed
