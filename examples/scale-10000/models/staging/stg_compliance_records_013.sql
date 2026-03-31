with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),
renamed as (
    select
        id as compliance_record_id
,        notes
,        reviewer_id
,        reviewed_at
    from source
)
select * from renamed
