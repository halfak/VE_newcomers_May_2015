source("loader/experimental_users.R")
source("loader/experimental_user_metrics.R")
source("loader/experimental_user_editing_sessions.R")

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

bucket_stats = first_5_sessions[via_mobile == 0,
    list(
        users = length(unique(user_id)),
        editor_ve.k = sum(editor == "visualeditor"),
        attempted.k = sum(outcome == "success" | !is.na(first_attempt)),
        successful.k = sum(outcome == "success"),
        sessions.n = sum(outcome != "abort_nochange" & outcome != "switch_editors")
    ),
    list(bucket)
][,
    list(
        users,
        editor_ve.k,
        editor_ve.p = editor_ve.k/sessions.n,
        attempted.k,
        attempted.p = attempted.k/sessions.n,
        successful.k,
        successful.p = successful.k/sessions.n,
        sessions.n
    ),
]
wiki.table(bucket_stats)

with(bucket_stats, prop.test(attempted.k, sessions.n))
with(bucket_stats, prop.test(successful.k, sessions.n))
