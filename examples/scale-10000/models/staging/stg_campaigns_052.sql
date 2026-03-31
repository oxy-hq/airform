with source as (
    select * from {{ source('raw', 'raw_campaigns') }}
),
renamed as (
    select
        id as campaign_id
,        spend
,        status
,        end_date
,        budget
    from source
)
select * from renamed
