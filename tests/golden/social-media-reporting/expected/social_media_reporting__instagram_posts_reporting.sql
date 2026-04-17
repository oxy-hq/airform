with report as (

    select *
    from instagram_business__posts

), fields as (

    select
        cast(account_name as TEXT) as page_name,
        cast(user_id as TEXT) as page_id,
        cast(post_caption as TEXT) as post_message,
        created_timestamp,
        cast(post_id as TEXT) as post_id,
        cast(post_url as TEXT) as post_url,
        source_relation,
        'instagram' as platform,
        coalesce(sum(comment_count),0) as comments,
        coalesce(sum(like_count),0) as likes,
       sum(
           coalesce(story_views, story_impressions, 0)
           + coalesce(video_photo_views, video_photo_impressions, 0)
       ) as impressions -- *_impressions are DEPRECATED, to be removed at a later time
    from report
    group by 1,2,3,4,5,6,7,8

)

select *
from fields
