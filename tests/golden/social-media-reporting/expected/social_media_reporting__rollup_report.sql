with unioned as (

    

        (
            select
                cast('"social_media_reporting"."main_social_media_reporting"."social_media_reporting__twitter_posts_reporting"' as TEXT) as _dbt_source_relation,

                /* No columns from any of the relations.
                   This star is only output during dbt compile, and exists to keep SQLFluff happy. */
                
                    *
                

                

            from "social_media_reporting"."main_social_media_reporting"."social_media_reporting__twitter_posts_reporting"

            
        )

        union all
        

        (
            select
                cast('"social_media_reporting"."main_social_media_reporting"."social_media_reporting__facebook_posts_reporting"' as TEXT) as _dbt_source_relation,

                /* No columns from any of the relations.
                   This star is only output during dbt compile, and exists to keep SQLFluff happy. */
                
                    *
                

                

            from "social_media_reporting"."main_social_media_reporting"."social_media_reporting__facebook_posts_reporting"

            
        )

        union all
        

        (
            select
                cast('"social_media_reporting"."main_social_media_reporting"."social_media_reporting__linkedin_posts_reporting"' as TEXT) as _dbt_source_relation,

                /* No columns from any of the relations.
                   This star is only output during dbt compile, and exists to keep SQLFluff happy. */
                
                    *
                

                

            from "social_media_reporting"."main_social_media_reporting"."social_media_reporting__linkedin_posts_reporting"

            
        )

        union all
        

        (
            select
                cast('"social_media_reporting"."main_social_media_reporting"."social_media_reporting__instagram_posts_reporting"' as TEXT) as _dbt_source_relation,

                /* No columns from any of the relations.
                   This star is only output during dbt compile, and exists to keep SQLFluff happy. */
                
                    *
                

                

            from "social_media_reporting"."main_social_media_reporting"."social_media_reporting__instagram_posts_reporting"

            
        )

        union all
        

        (
            select
                cast('"social_media_reporting"."main_social_media_reporting"."social_media_reporting__youtube_videos_reporting"' as TEXT) as _dbt_source_relation,

                /* No columns from any of the relations.
                   This star is only output during dbt compile, and exists to keep SQLFluff happy. */
                
                    *
                

                

            from "social_media_reporting"."main_social_media_reporting"."social_media_reporting__youtube_videos_reporting"

            
        )

        

)

select *
from unioned
