with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        category
,        reviewed_at
,        reviewer_id
,        notes
,        record_type
,        created_at
    from source
)
select * from renamed
