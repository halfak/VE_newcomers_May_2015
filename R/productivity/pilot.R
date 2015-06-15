source("loader/pilot_users.R")
source("loader/pilot_user_metrics.R")


users = load.pilot_users(reload=T)
metrics = load.pilot_user_metrics(reload=T)

user_metrics = merge(users, metrics, by="user_id")

user_metrics$editing = user_metrics$day_revisions > 0
user_metrics$main_editing = user_metrics$day_main_revisions > 0
user_metrics$talk_editing = user_metrics$day_talk_revisions > 0
user_metrics$user_editing = user_metrics$day_user_revisions > 0
user_metrics$wp_editing = user_metrics$day_wp_revisions > 0
user_metrics$editing = user_metrics$day_revisions > 0
user_metrics$productive = user_metrics$day_main_revisions >
                          user_metrics$day_reverted_main_revisions

user_metrics[,
    list(
        editing.k = sum(editing),
        main_editing.k = sum(main_editing),
        talk_editing.k = sum(talk_editing),
        user_editing.k = sum(user_editing),
        wp_editing.k = sum(wp_editing),
        productive.k = sum(productive),
        enabled.k = sum(ve_enabled),
        n = length(user_id)
    ),
    list(
        bucket,
        via_mobile
    )
]
