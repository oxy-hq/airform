with source as (
    select * from {{ source('raw', 'raw_employees') }}
),

renamed as (
    select
        id as employee_id
,        first_name
,        title
,        last_name
    from source
)

select * from renamed
