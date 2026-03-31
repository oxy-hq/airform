with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        status
,        title
,        department_id
,        manager_id
,        email
    from source
)
select * from renamed
