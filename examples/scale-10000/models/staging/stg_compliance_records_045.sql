with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        created_at
,        risk_level
,        record_type
,        reviewed_at
,        notes
,        reviewer_id
,        category
    from source
)
select * from renamed
