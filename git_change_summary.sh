# Script which summarises changes made which are not committed into git, for
# the purposes of annotating PDFs.
[ "$(git status --porcelain | wc -l)" -gt "0" ] && (
	echo "Built on $(date). Draft includes some uncommitted changes:\\\\"
	git status --porcelain | while read change; do
		echo "\\verb|$change|$\\quad$"
	done
)
