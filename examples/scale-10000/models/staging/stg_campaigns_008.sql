with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        start_date
,        end_date
,        status
,        spend
,        channel
    from source
)
select * from renamed
