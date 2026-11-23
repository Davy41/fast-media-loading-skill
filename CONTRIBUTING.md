# Contributing

Thanks for helping improve this skill.

## Ways to help

- Report wrong or outdated advice (codec settings, framework options, header values).
- Add framework notes to `skills/fast-media-loading/references/frameworks.md`.
- Improve `scripts/audit-media.sh`, for example to handle multi-line tags.
- Share a case where the skill gave a bad result, with the project type and prompt.

## Guidelines

- Keep `SKILL.md` short. Put detail in `references/` and link to it.
- Keep the `description` in the `SKILL.md` frontmatter specific about when the skill should be used.
- Scripts must be read-only unless clearly documented, and must work with standard `bash`, `find` and `grep`.
- Test changes by installing the skill locally and running it on a real project.
- Add an entry to `CHANGELOG.md` under "Unreleased".

## Pull requests

1. Fork and create a branch.
2. Make your change and test it.
3. Open a pull request describing what changed and why.
