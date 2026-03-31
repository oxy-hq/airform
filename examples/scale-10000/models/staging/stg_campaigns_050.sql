with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        target_audience
,        channel
,        budget
,        start_date
,        status
,        spend
,        end_date
    from source
)
select * from renamed
