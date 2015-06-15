source("loader/experimental_users.R")
source("loader/experimental_user_metrics.R")
source("loader/experimental_user_editing_sessions.R")

library(plyr)

users = load.experimental_users(reload=T)
metrics = load.experimental_user_metrics(reload=T)
edit_sessions = load.experimental_user_editing_sessions(reload=T)

ve_sessions = nrow(edit_sessions[editor == "visualeditor"])
resampled_edit_sessions = rbind(
    edit_sessions[editor == "wikitext",],
    edit_sessions[editor == "visualeditor"][
        sample(ve_sessions, ve_sessions/4)
    ]
)
user_edit_sessions = merge(users, resampled_edit_sessions, by="user_id")
user_edit_sessions[,
    list(
        count = length(user_id)
    ),
    list(bucket)
]

user_edit_sessions[bucket=="experimental",
    list(
        count = length(bucket)
    ),
    list(user_id)
][order(count, decreasing=T)][1:10]

user_edit_sessions[bucket=="control",
    list(
        count = length(bucket)
    ),
    list(user_id)
][order(count, decreasing=T)][1:10]

first_5_sessions = user_edit_sessions[, j = {.SD[order(session_started),][1:min(5, .N),]}, by=user_id]
first_5_sessions[,
    list(
        count = length(user_id)
    ),
    list(bucket)
]

wiki.table(
first_5_sessions[,
    list(
        users.n = length(unique(user_id)),
        ve.k = sum(editor == "visualeditor"),
        ve.p = sum(editor == "visualeditor")/length(session_id),
        attempted.k = sum(outcome == "success" | !is.na(first_attempt)),
        attempted.p = sum(outcome == "success" | !is.na(first_attempt))/length(session_id),
        successful.k = sum(outcome == "success"),
        successful.p = sum(outcome == "success")/length(session_id),
        changed_and_noswitch.n = sum(outcome != "abort_nochange" & outcome != "switch_editors"),
        changed.n = sum(outcome != "abort_nochange"),
        n = length(session_id)
    ),
    list(bucket, via_mobile)
]
)

user_session_count = resampled_edit_sessions[,
    list(editing_sessions = length(session_id)),
    user_id
]
merge(
    users,
    merge(metrics, user_session_count, by="user_id", all=T),
    by="user_id"
)[,
    list(
        has_editing_sessions.k = sum(!is.na(editing_sessions) | day_revisions > 0),
        editing.n = sum(day_revisions > 0)
    ),
    list(bucket, via_mobile)
]


svg("edit_success/plots/hist_of_time_to_save.svg", height=5, width=7)
ggplot(
    first_5_sessions[outcome == "attempt" | outcome == "success",],
    aes(
        x = as.numeric(first_attempt - session_started, units="secs")+1
    )
) +
theme_bw() +
geom_density(fill="#0000FF", alpha=0.5) +
scale_x_log10(
    "Seconds since session start",
    breaks=c(0, 1, 5, 10, 60, 10*60, 50*60)+1,
    labels=c("0", "1s", "5s", "10s", "1 min", "10 min", "50 min")
)
dev.off()


svg("edit_success/plots/hist_of_time_to_save.by_bucket.svg", height=5, width=7)
ggplot(
    first_5_sessions[outcome == "attempt" | outcome == "success",],
    aes(
        x = as.numeric(first_attempt - session_started, units="secs")+1,
        group = bucket,
        fill = bucket
    )
) +
theme_bw() +
geom_density(alpha=0.4) +
scale_x_log10(
    "Seconds since session start",
    breaks=c(0, 1, 5, 10, 60, 10*60, 50*60)+1,
    labels=c("0", "1s", "5s", "10s", "1 min", "10 min", "50 min")
)
dev.off()


t.test(
    with(
        first_5_sessions[
            first_attempt > session_started &
            bucket == "control" &
            (outcome == "attempt" | outcome == "success"),
        ],
        log(as.numeric(first_attempt - session_started, units="secs"))
    ),
    with(
        first_5_sessions[
            first_attempt > session_started &
            bucket == "experimental" &
            (outcome == "attempt" | outcome == "success"),
        ],
        log(as.numeric(first_attempt - session_started, units="secs"))
    )
)

svg("edit_success/plots/hist_of_time_to_save.by_editor.svg", height=5, width=7)
ggplot(
    first_5_sessions[bucket == "experimental" | outcome == "attempt" | outcome == "success",],
    aes(
        x = as.numeric(first_attempt - session_started, units="secs")+1,
        group = editor,
        fill = editor
    )
) +
theme_bw() +
geom_density(alpha=0.4) +
scale_x_log10(
    "Seconds since session start",
    breaks=c(0, 1, 5, 10, 35, 2*60, 50*60)+1,
    labels=c("0", "1s", "5s", "10s", "35s", "2 min", "50 min")
)
dev.off()
