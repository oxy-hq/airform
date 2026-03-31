with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        salary
,        department_id
,        title
,        manager_id
,        email
,        last_name
    from source
)
select * from renamed
