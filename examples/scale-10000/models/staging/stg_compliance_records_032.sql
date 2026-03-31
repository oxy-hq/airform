with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        risk_level
,        notes
,        reviewer_id
,        reviewed_at
,        category
,        account_id
    from source
)
select * from renamed
