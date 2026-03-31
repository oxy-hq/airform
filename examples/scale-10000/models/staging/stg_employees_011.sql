with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        department_id
,        manager_id
,        title
,        salary
,        email
,        last_name
    from source
)
select * from renamed
