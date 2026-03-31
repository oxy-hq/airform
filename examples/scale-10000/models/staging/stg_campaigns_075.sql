with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        budget
,        channel
,        end_date
,        spend
,        status
,        target_audience
,        campaign_name
    from source
)
select * from renamed
