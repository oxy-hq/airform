with source as (
    select * from {{ source('raw', 'raw_departments') }}
),

renamed as (
    select
        id as department_id
,        location
,        budget
,        region
    from source
)

select * from renamed
