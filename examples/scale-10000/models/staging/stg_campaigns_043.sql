with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        end_date
,        spend
,        budget
,        target_audience
,        status
    from source
)
select * from renamed
