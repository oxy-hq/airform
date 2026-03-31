with source as (
    select * from {{ source('raw', 'raw_departments') }}
),

renamed as (
    select
        id as department_id
,        region
,        budget
,        created_at
,        parent_id
,        head_count
,        department_name
,        status
    from source
)

select * from renamed
