with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        location
,        department_name
,        parent_id
,        head_count
,        budget
,        created_at
    from source
)
select * from renamed
