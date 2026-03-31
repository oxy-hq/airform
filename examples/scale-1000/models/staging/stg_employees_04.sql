with source as (
    select * from {{ source('raw', 'raw_employees') }}
),

renamed as (
    select
        id as employee_id
,        last_name
,        department_id
,        email
,        title
,        manager_id
    from source
)

select * from renamed
