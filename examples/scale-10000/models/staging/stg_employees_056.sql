with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        department_id
,        hire_date
,        status
,        email
    from source
)
select * from renamed
