with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        budget
,        parent_id
,        region
,        head_count
,        created_at
,        department_name
,        location
    from source
)
select * from renamed
