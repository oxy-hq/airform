with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),

renamed as (
    select
        id as campaign_id
,        spend
,        budget
,        target_audience
,        status
,        channel
,        start_date
,        end_date
    from source
)

select * from renamed
