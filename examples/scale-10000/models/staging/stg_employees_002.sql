with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        first_name
,        last_name
,        department_id
,        status
    from source
)
select * from renamed
