with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        department_name
,        created_at
,        status
,        budget
    from source
)
select * from renamed
