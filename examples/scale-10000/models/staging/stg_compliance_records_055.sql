with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        category
,        record_type
,        risk_level
,        reviewer_id
    from source
)
select * from renamed
