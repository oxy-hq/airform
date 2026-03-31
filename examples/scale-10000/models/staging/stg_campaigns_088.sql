with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        status
,        end_date
,        target_audience
,        spend
    from source
)
select * from renamed
