figure="$1"
output="$2"

while inotifywait $(python buildfig.py "$figure" -d); do
	sleep 0.1
	python buildfig.py "$figure" -o "$output"
done
