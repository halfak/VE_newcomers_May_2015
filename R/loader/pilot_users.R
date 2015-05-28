source("env.R")
source("util.R")

load.pilot_users = tsv_loader(
	paste(DATA_DIR, "pilot_users.tsv", sep="/"),
	"PILOT_USERS",
    function(df){
        names(df)
        df$registration = as.POSIXct(
            as.character(df$registration),
            origin="1970-01-01",
            format="%Y%m%d%H%M%S"
        )
        df
    }
)
