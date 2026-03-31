with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        end_date
,        target_audience
,        start_date
,        spend
,        goal
,        campaign_name
    from source
)
select * from renamed
