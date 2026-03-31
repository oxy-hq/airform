with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        reviewed_at
,        account_id
,        reviewer_id
,        record_type
,        notes
,        category
    from source
)
select * from renamed
