with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        risk_level
,        status
,        notes
,        category
,        created_at
,        account_id
,        record_type
    from source
)
select * from renamed
