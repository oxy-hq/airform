with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        channel
,        status
,        end_date
,        budget
,        target_audience
    from source
)
select * from renamed
