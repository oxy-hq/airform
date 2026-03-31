with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        category
,        created_at
,        record_type
,        notes
,        reviewer_id
,        reviewed_at
,        account_id
    from source
)
select * from renamed
