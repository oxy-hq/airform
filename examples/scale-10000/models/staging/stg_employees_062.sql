with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        title
,        email
,        hire_date
,        department_id
,        status
,        last_name
,        salary
    from source
)
select * from renamed
