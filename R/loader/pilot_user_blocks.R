source("env.R")
source("util.R")

load.pilot_user_blocks = tsv_loader(
	paste(DATA_DIR, "pilot_user_blocks.tsv", sep="/"),
	"PILOT_USER_BLOCKS"
)
