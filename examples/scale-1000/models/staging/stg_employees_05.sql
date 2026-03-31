with source as (
    select * from {{ source('raw', 'raw_employees') }}
),

renamed as (
    select
        id as employee_id
,        salary
,        first_name
,        title
,        department_id
    from source
)

select * from renamed
