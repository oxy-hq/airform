with source as (
    select * from {{ source('raw', 'raw_employees') }}
),
renamed as (
    select
        id as employee_id
,        last_name
,        title
,        salary
    from source
)
select * from renamed
