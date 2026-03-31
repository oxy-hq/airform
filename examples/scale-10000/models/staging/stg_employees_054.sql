with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        hire_date
,        title
,        manager_id
,        department_id
,        salary
,        email
    from source
)
select * from renamed
