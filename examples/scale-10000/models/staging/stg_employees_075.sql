with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        title
,        first_name
,        department_id
    from source
)
select * from renamed
