with source as (
    select * from {{ source('raw', 'raw_departments') }}
),

renamed as (
    select
        id as department_id
,        head_count
,        budget
,        region
,        created_at
,        department_name
    from source
)

select * from renamed
