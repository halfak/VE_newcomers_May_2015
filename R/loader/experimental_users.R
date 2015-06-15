source("env.R")
source("util.R")

load.experimental_users = tsv_loader(
	paste(DATA_DIR, "experimental_users.tsv", sep="/"),
	"EXPERIMENTAL_USERS",
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
