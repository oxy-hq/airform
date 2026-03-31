with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        record_type
,        category
,        created_at
,        account_id
,        reviewer_id
,        risk_level
    from source
)
select * from renamed
