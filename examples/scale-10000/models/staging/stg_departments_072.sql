with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        department_name
,        head_count
,        parent_id
,        region
,        budget
,        location
,        created_at
    from source
)
select * from renamed
