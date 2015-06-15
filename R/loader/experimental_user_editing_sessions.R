source("env.R")
source("util.R")

load.experimental_user_editing_sessions = tsv_loader(
	paste(DATA_DIR, "experimental_user_editing_sessions.tsv", sep="/"),
	"experimental_USER_EDITING_SESSIONS",
    function(df){
        df$session_started = as.POSIXct(
            as.character(df$session_started),
            origin="1970-01-01",
            format="%Y%m%d%H%M%S"
        )
        df$editor_ready = as.POSIXct(
            as.character(df$editor_ready),
            origin="1970-01-01",
            format="%Y%m%d%H%M%S"
        )
        df$first_attempt = as.POSIXct(
            as.character(df$first_attempt),
            origin="1970-01-01",
            format="%Y%m%d%H%M%S"
        )
        df$session_ended = as.POSIXct(
            as.character(df$session_ended),
            origin="1970-01-01",
            format="%Y%m%d%H%M%S"
        )
        df
    }
)
