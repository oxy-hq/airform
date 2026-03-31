with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),

renamed as (
    select
        id as campaign_id
,        end_date
,        spend
,        status
,        target_audience
    from source
)

select * from renamed
