with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        department_id
,        email
,        status
,        salary
    from source
)
select * from renamed
