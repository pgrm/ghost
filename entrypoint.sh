#!/bin/bash
set -e

if [[ "$*" == npm*start* ]]; then
	for dir in "$GHOST_SOURCE/content"/*/; do
		targetDir="$GHOST_CONTENT/$(basename "$dir")"
		mkdir -p "$targetDir"
		if [ -z "$(ls -A "$targetDir")" ]; then
			tar -c --one-file-system -C "$dir" . | tar xC "$targetDir"
		fi
	done

	if [ ! -e "$GHOST_CONTENT/config.js" ]; then
		sed -r '
			s/127\.0\.0\.1/0.0.0.0/g;
			s!path.join\(__dirname, (.)/content!path.join(process.env.GHOST_CONTENT, \1!g;
		' "$GHOST_SOURCE/config.example.js" > "$GHOST_CONTENT/config.js"
	fi

	ln -sf "$GHOST_CONTENT/config.js" "$GHOST_SOURCE/config.js"

	chown -R user "$GHOST_CONTENT"

	set -- gosu user "$@"
fi

sed -ir "s/var ga_ua = '.*';/var ga_ua = '$GA_UA';/g;
		s/var disqus_shortname = '.*'/var disqus_shortname = '$DISQUS_SHORTNAME'/g"
	"$GHOST_CONTENT/content/themes/Perfetta-Free-Ghost-Theme-v.1.5.0/partials/config.hbs"

sed -ir "s#url: '.*'#$URL/g" "$GHOST_SOURCE/config.js"

exec "$@"