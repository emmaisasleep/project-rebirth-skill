#!/bin/bash

# API routes and endpoints

rg -n "router\.|app\.(get|post|put|delete|patch)|@(Get|Post|Put|Delete|Patch|Controller|RequestMapping)" --type-add 'web:*.{ts,js,tsx,jsx,py,java,go,rs}' -tweb

# Data models and schemas

rg -n "schema|model|entity|table|migration|@Column|@Entity|@Table|class.*Model" --type-add 'code:*.{ts,js,py,java,go,rs,rb}' -tcode

# Test descriptions (reveal expected behavior)

rg -n "(describe|it|test|expect)\(" --type-add 'test:*.{test.*,spec.*,_test.*}' -ttest | head -100

# Environment/config (reveals integrations)

rg -n "process\.env|os\.environ|env\.|config\." | head -50
