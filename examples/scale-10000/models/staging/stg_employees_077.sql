with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        salary
,        email
,        first_name
,        department_id
,        manager_id
    from source
)
select * from renamed
