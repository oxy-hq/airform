with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        location
,        created_at
,        budget
    from source
)
select * from renamed
