with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        created_at
,        budget
,        head_count
,        parent_id
,        department_name
    from source
)
select * from renamed
