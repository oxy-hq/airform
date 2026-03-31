with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        email
,        hire_date
,        first_name
,        department_id
,        title
,        manager_id
,        salary
    from source
)
select * from renamed
