#!/bin/sh
# Turn the template into your package: tools/rename.sh NAME (lowercase letters and digits).
# It renames mypackage / MyPackage in the files and their names, and the Java package.
set -e
cd "$(dirname "$0")/.."
name="$1"
case "$name" in
    ''|*[!a-z0-9]*|[0-9]*) echo "usage: tools/rename.sh NAME (lowercase letters and digits, not first a digit)"; exit 2 ;;
esac
# MyPackage -> Name (the first letter in capitals) for the Java class.
class="$(printf '%s' "$name" | cut -c1 | tr '[:lower:]' '[:upper:]')$(printf '%s' "$name" | cut -c2-)"
files=$(grep -rl 'mypackage\|MyPackage' --exclude-dir=.git --exclude-dir=build --exclude=rename.sh . || true)
for f in $files; do
    sed -i.bak -e "s/MyPackage/$class/g" -e "s/mypackage/$name/g" "$f" && rm "$f.bak"
done
for f in $(find . -path ./.git -prune -o -name '*mypackage*' -print -o -name '*MyPackage*' -print); do
    new=$(echo "$f" | sed -e "s/MyPackage/$class/g" -e "s/mypackage/$name/g")
    mv "$f" "$new"
done
rm -f eskiu.lock examples/demo/eskiu.lock
echo "Renamed to $name (class $class). Next: edit README.md and src/$name.esk, then eskiuc test."
