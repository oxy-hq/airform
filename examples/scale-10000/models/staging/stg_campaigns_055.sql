with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        campaign_name
,        spend
,        target_audience
,        channel
,        budget
    from source
)
select * from renamed
