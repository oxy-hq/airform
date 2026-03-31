with source as (
    select * from {{ source('raw', 'raw_departments') }}
),
renamed as (
    select
        id as department_id
,        head_count
,        created_at
,        location
    from source
)
select * from renamed
