with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        manager_id
,        email
,        hire_date
,        department_id
,        title
,        salary
    from source
)
select * from renamed
