with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        category
,        reviewed_at
,        created_at
,        reviewer_id
,        record_type
,        risk_level
,        status
    from source
)
select * from renamed
