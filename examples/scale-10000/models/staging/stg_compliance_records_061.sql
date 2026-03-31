with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        category
,        risk_level
,        created_at
,        account_id
,        notes
,        record_type
,        reviewed_at
    from source
)
select * from renamed
