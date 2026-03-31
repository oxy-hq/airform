with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        campaign_name
,        end_date
,        status
,        spend
,        goal
,        target_audience
    from source
)
select * from renamed
