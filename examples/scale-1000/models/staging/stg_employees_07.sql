with source as (
    select * from {{ source('raw', 'raw_employees') }}
),

renamed as (
    select
        id as employee_id
,        email
,        status
,        department_id
,        salary
    from source
)

select * from renamed
