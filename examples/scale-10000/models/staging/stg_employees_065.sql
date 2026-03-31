with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        email
,        manager_id
,        department_id
,        status
,        title
    from source
)
select * from renamed
