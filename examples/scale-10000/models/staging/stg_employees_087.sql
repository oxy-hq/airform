with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        manager_id
,        email
,        department_id
    from source
)
select * from renamed
