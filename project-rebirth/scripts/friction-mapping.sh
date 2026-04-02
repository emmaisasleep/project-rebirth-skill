#!/bin/bash

# Technical debt markers

rg -n "TODO|FIXME|HACK|WORKAROUND|XXX|TEMP|DEPRECATED" --stats-only
rg -n "TODO|FIXME|HACK|WORKAROUND" | head -50

# Complexity signals (deep nesting, long files)

find . -name '*.ts' -o -name '*.js' -o -name '*.py' -o -name '*.java' | \
  xargs wc -l 2>/dev/null | sort -rn | head -20

# Dependency bloat

cat package.json 2>/dev/null | python3 -c "
import json, sys
d = json.load(sys.stdin)
deps = {**d.get('dependencies',{}), **d.get('devDependencies',{})}
print(f'Total deps: {len(deps)}')
for k,v in sorted(deps.items()):
    print(f'  {k}: {v}')
" 2>/dev/null

# Circular or tangled imports

rg -n "^(import|from|require)" --type-add 'code:*.{ts,js,py}' -tcode | \
  awk -F: '{print $1}' | sort | uniq -c | sort -rn | head -20
