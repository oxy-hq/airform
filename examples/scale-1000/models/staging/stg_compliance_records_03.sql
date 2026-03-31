with source as (
    select * from {{ source('raw', 'raw_compliance_records') }}
),

renamed as (
    select
        id as compliance_record_id
,        notes
,        record_type
,        reviewer_id
    from source
)

select * from renamed
