with source as (
    select * from {{ source('raw', 'raw_employees') }}
),

renamed as (
    select
        id as employee_id
,        title
,        hire_date
,        department_id
    from source
)

select * from renamed
